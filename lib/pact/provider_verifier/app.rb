require 'pact/provider_verifier/add_header_middlware'
require 'pact/provider_verifier/provider_states/add_provider_states_header'
require 'pact/provider_verifier/provider_states/remove_provider_states_header_middleware'
require 'pact/provider_verifier/custom_middleware'
require 'pact/provider/rspec'
require 'pact/message'
require 'pact/cli/run_pact_verification'
require 'pact/provider_verifier/aggregate_pact_configs'
require 'rack/reverse_proxy'
require 'faraday_middleware'
require 'json'

module Pact
  module ProviderVerifier
    class App

      PROXY_PACT_HELPER = File.expand_path(File.join(File.dirname(__FILE__), "pact_helper.rb"))

      def initialize pact_urls, options = {}
        @pact_urls = pact_urls
        @options = options
        @consumer_version_tags = options[:consumer_version_tag] || []
      end

      def self.call pact_urls, options
        new(pact_urls, options).call
      end

      def call
        setup

        exit_statuses = all_pact_urls.collect do |pact_url|
          verify_pact pact_url
        end

        exit_statuses.all?{ | status | status == 0 }
      end

      private

      attr_reader :pact_urls, :options, :consumer_version_tags

      def setup
        print_deprecation_note
        set_environment_variables
        require_rspec_monkeypatch_for_jsonl
        require_pact_project_pact_helper # Beth: not sure if this is needed, hangover from pact-provider-proxy?
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

        provider_application_version = options.provider_app_version
        publish_results  = options.publish_verification_results

        Pact.service_provider "Running Provider Application" do
          app do
            application
          end

          if provider_application_version
            app_version provider_application_version
          end

          publish_verification_results publish_results
        end
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
          $stdout.puts "DEBUG: Requiring custom middleware file #{file}" if options.verbose
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

      def verify_pact(config)
        begin
          verify_options = {
            pact_helper: PROXY_PACT_HELPER,
            pact_uri: config.uri,
            backtrace: ENV['BACKTRACE'] == 'true',
            pact_broker_username: options.broker_username,
            pact_broker_password: options.broker_password,
            format: options.format,
            out: options.out,
            ignore_failures: config.pending,
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
        configure_service_provider
      end

      def all_pact_urls
        http_client_options = { username: options.broker_username, password: options.broker_password }
        AggregatePactConfigs.call(pact_urls, options.provider, consumer_version_tags, options.pact_broker_base_url, http_client_options)
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

      def print_deprecation_note
        if options.provider_states_url
          $stderr.puts "WARN: The --provider-states-url option is deprecated and the URL endpoint can be removed from the application"
        end
      end
    end
  end
end


