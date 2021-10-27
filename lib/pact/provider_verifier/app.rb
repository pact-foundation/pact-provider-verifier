require 'pact/wait_until_server_available'
require 'pact/provider_verifier/add_header_middlware'
require 'pact/provider_verifier/provider_states/add_provider_states_header'
require 'pact/provider_verifier/provider_states/remove_provider_states_header_middleware'
require 'pact/provider_verifier/custom_middleware'
require 'pact/provider/rspec'
require 'pact/message'
require 'pact/cli/run_pact_verification'
require 'pact/provider_verifier/aggregate_pact_configs'
require 'pact/provider_verifier/git'
require 'rack/reverse_proxy'
require 'faraday_middleware'
require 'json'

module Pact
  module ProviderVerifier
    class App
      include Pact::WaitUntilServerAvailable

      PROXY_PACT_HELPER = File.expand_path(File.join(File.dirname(__FILE__), "pact_helper.rb"))
      EMPTY_ARRAY = [].freeze
      attr_reader :pact_urls, :options, :consumer_version_tags, :provider_version_branch, :provider_version_tags, :consumer_version_selectors, :publish_verification_results

      def initialize pact_urls, options = {}
        @pact_urls = pact_urls
        @options = options
        @consumer_version_tags = options.consumer_version_tag || EMPTY_ARRAY
        @provider_version_tags = merge_provider_version_tags(options)
        @provider_version_branch = options.provider_version_branch
        @consumer_version_selectors = parse_consumer_version_selectors(options.consumer_version_selector || EMPTY_ARRAY)
        @publish_verification_results = options.publish_verification_results || ENV['PACT_BROKER_PUBLISH_VERIFICATION_RESULTS'] == 'true'
      end

      def self.call pact_urls, options
        new(pact_urls, options).call
      end

      def call
        setup
        warn_empty_pact_set
        wait_until_provider_available
        pacts_pass_verification?
      end

      private

      def pacts_pass_verification?
        return false if all_pact_urls.empty? && options.fail_if_no_pacts_found

        exit_statuses = all_pact_urls.collect do |pact_uri|
          verify_pact pact_uri
        end

        exit_statuses.all?{ | status | status == 0 }
      end


      def setup
        configure_output
        print_deprecation_note
        set_environment_variables
        require_rspec_monkeypatch_for_jsonl
        require_pact_project_pact_helper # Beth: not sure if this is needed, hangover from pact-provider-proxy?
        set_broker_token_env_var
      end

      def set_environment_variables
        ENV['PROVIDER_STATES_SETUP_URL'] = options.provider_states_setup_url
        ENV['VERBOSE_LOGGING'] = options.verbose if options.verbose
        ENV['CUSTOM_PROVIDER_HEADER'] = custom_provider_headers_for_env_var if custom_provider_headers_for_env_var
        ENV['MONKEYPATCH'] = options.monkeypatch.join("\n") if options.monkeypatch && options.monkeypatch.any?
      end

      def configure_service_provider
        # Have to declare these locally as the class scope gets lost within the block
        application = configure_reverse_proxy
        application = configure_provider_states_header_removal_middleware(application)
        application = configure_custom_middleware(application)
        application = configure_custom_header_middleware(application)

        this = self

        Pact.service_provider "Running Provider Application" do
          app do
            application
          end

          if this.options.provider_app_version
            app_version this.options.provider_app_version
          end

          if this.options.provider_version_branch
            app_version_branch this.options.provider_version_branch
          end

          if this.provider_version_tags.any?
            app_version_tags this.provider_version_tags
          end

          publish_verification_results this.publish_verification_results
        end
      end

      def configure_output
        if options[:format] && !options[:out]
          # Don't want to mess up the JSON parsing with messages to stdout, so send it to stderr
          require 'pact/configuration'
          Pact.configuration.output_stream = Pact.configuration.error_stream
        end
        Pact.configuration.log_dir = options.log_dir if options.log_dir
        Pact.configuration.logger.level = Kernel.const_get('Logger').const_get(options.log_level.upcase) if options.log_level
      end

      def configure_reverse_proxy
        provider_base_url = options.provider_base_url
        Rack::ReverseProxy.new do
          reverse_proxy_options(
            verify_mode: OpenSSL::SSL::VERIFY_NONE,
            preserve_host: true,
            x_forwarded_headers: false
          )
          reverse_proxy %r{(.*)}, "#{provider_base_url}$1"
        end
      end

      def configure_custom_header_middleware rack_reverse_proxy
        if options.custom_provider_header
          Pact::ProviderVerifier::AddHeaderMiddlware.new(rack_reverse_proxy, parse_header)
        else
          rack_reverse_proxy
        end
      end

      def configure_custom_middleware app
        if options.custom_middleware && options.custom_middleware.any?
          require_custom_middlware
          apply_custom_middleware(app)
        else
          app
        end
      end

      def configure_provider_states_header_removal_middleware app
        ProviderStates::RemoveProviderStatesHeaderMiddleware.new(app)
      end

      def require_custom_middlware
        options.custom_middleware.each do |file|
          $stdout.puts "DEBUG: Requiring custom middleware file #{file}" if verbose?
          begin
            require file
          rescue LoadError => e
            $stderr.puts "ERROR: #{e.class} - #{e.message}. Please specify an absolute path."
            exit(1)
          end
        end
      end

      def apply_custom_middleware app
        CustomMiddleware.descendants.inject(app) do | app, clazz |
          Pact.configuration.output_stream.puts "INFO: Adding custom middleware #{clazz}"
          clazz.new(app)
        end
      end

      def verify_pact(pact_uri)
        begin
          verify_options = {
            pact_helper: PROXY_PACT_HELPER,
            pact_uri: pact_uri,
            backtrace: ENV['BACKTRACE'] == 'true',
            verbose: verbose?,
            format: options.format,
            out: options.out,
            request_customizer: ProviderStates::AddProviderStatesHeader
          }
          verify_options[:description] = ENV['PACT_DESCRIPTION'] if ENV['PACT_DESCRIPTION']
          verify_options[:provider_state] = ENV['PACT_PROVIDER_STATE'] if ENV['PACT_PROVIDER_STATE']

          reset_pact_configuration
          # Really, this should call the PactSpecRunner directly, rather than using the CLI class.
          Cli::RunPactVerification.call(verify_options)
        rescue SystemExit => e
          e.status
        end
      end

      def reset_pact_configuration
        require 'pact/configuration'
        require 'pact/consumer/world'
        require 'pact/provider/world'
        Pact.clear_configuration
        Pact.clear_consumer_world
        Pact.clear_provider_world
        configure_output
        configure_service_provider
      end

      def all_pact_urls
        @all_pact_urls ||= begin
          http_client_options = {
            username: options.broker_username || ENV['PACT_BROKER_USERNAME'],
            password: options.broker_password || ENV['PACT_BROKER_PASSWORD'],
            token: options.broker_token || ENV['PACT_BROKER_TOKEN'],
            verbose: verbose?
          }
          opts = {
            enable_pending: options.enable_pending,
            include_wip_pacts_since: options.include_wip_pacts_since
          }
          AggregatePactConfigs.call(
            pact_urls,
            options.provider,
            consumer_version_tags,
            consumer_version_selectors,
            provider_version_branch,
            provider_version_tags,
            options.pact_broker_base_url || ENV['PACT_BROKER_BASE_URL'],
            http_client_options,
            opts)
        end
      end

      def warn_empty_pact_set
        if all_pact_urls.empty?
          level = options.fail_if_no_pacts_found ? "ERROR" : "WARN"
          $stderr.puts  "#{level}: No pacts were found for the consumer versions selected"
        end
      end

      def require_pact_project_pact_helper
        require ENV['PACT_PROJECT_PACT_HELPER'] if ENV.fetch('PACT_PROJECT_PACT_HELPER','') != ''
      end

      def require_rspec_monkeypatch_for_jsonl
        if options.format == 'json'
          require 'pact/provider_verifier/rspec_json_formatter_monkeypatch'
        end
      end

      def custom_provider_headers_for_env_var
        if options.custom_provider_header && options.custom_provider_header.any?
          options.custom_provider_header.join("\n")
        end
      end

      def parse_header
        options.custom_provider_header.each_with_object({}) do | custom_provider_header, header_hash |
          header_name, header_value = custom_provider_header.split(":", 2).collect(&:strip)
          header_hash[header_name] = header_value
        end
      end

      def parse_consumer_version_selectors consumer_version_selectors
        consumer_version_selectors.collect{ | string | JSON.parse(string, symbolize_names: true) }
      end

      def merge_provider_version_tags(options)
        (options.provider_version_tag || EMPTY_ARRAY) + (options.tag_with_git_branch ? [Git.branch] : EMPTY_ARRAY)
      end

      def print_deprecation_note
        if options.provider_states_url
          $stderr.puts "WARN: The --provider-states-url option is deprecated and the URL endpoint can be removed from the application"
        end
      end

      def wait_until_provider_available
        if options.wait && options.wait != 0
          uri = URI(options.provider_base_url)
          $stderr.puts "INFO: Polling for up to #{options.wait} seconds for provider to become available at #{uri.host}:#{uri.port}..."
          up = wait_until_server_available(uri.host, uri.port, options.wait)
          if up
            $stderr.puts "INFO: Provider available, proceeding with verifications"
          else
            $stderr.puts "WARN: Provider does not appear to be up on #{uri.host}:#{uri.port}... proceeding with verifications anyway"
          end
        end
      end

      def set_broker_token_env_var
        if options.broker_token && !ENV['PACT_BROKER_TOKEN']
          ENV['PACT_BROKER_TOKEN'] = options.broker_token
        end
      end

      def verbose?
        options.verbose || ENV['VERBOSE'] == 'true'
      end
    end
  end
end
