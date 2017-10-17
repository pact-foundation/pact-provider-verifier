require 'pact/provider_verifier/add_header_middlware'
require 'pact/provider/rspec'
require 'pact/cli/run_pact_verification'
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
      end

      def self.call pact_urls, options
        new(pact_urls, options).call
      end

      def call
        setup

        exit_statuses = pact_urls.collect do |pact_url|
          verify_pact pact_url
        end

        # Return non-zero exit code if failures - increment for each Pact
        exit exit_statuses.count{ | status | status != 0 }
      end

      private

      attr_reader :pact_urls, :options

      def setup
        print_deprecation_note
        set_environment_variables
        configure_service_provider
        require_pact_project_pact_helper # Beth: not sure if this is needed, hangover from pact-provider-proxy?
      end

      def set_environment_variables
        ENV['PROVIDER_STATES_SETUP_URL'] = options.provider_states_setup_url
        ENV['VERBOSE_LOGGING'] = options.verbose if options.verbose
        ENV['CUSTOM_PROVIDER_HEADER'] = custom_provider_headers_for_env_var if custom_provider_headers_for_env_var
      end

      def configure_service_provider
        # Have to declare these locally as the class scope gets lost within the block
        rack_reverse_proxy = configure_reverse_proxy
        rack_reverse_proxy = configure_custom_header_middlware(rack_reverse_proxy)

        provider_application_version = options.provider_app_version
        publish_results  = options.publish_verification_results

        Pact.service_provider "Running Provider Application" do
          app do
            rack_reverse_proxy
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
          reverse_proxy '/', provider_base_url
        end
      end

      def configure_custom_header_middlware rack_reverse_proxy
        if options.custom_provider_header
          Pact::ProviderVerifier::AddHeaderMiddlware.new(rack_reverse_proxy, parse_header)
        else
          rack_reverse_proxy
        end
      end

      def verify_pact pact_url
        begin
          verify_options = {
            :pact_helper => PROXY_PACT_HELPER,
            :pact_uri => pact_url,
            :backtrace => ENV['BACKTRACE'] == 'true',
            :pact_broker_username => options.broker_username,
            :pact_broker_password => options.broker_password
          }
          verify_options[:description] = ENV['PACT_DESCRIPTION'] if ENV['PACT_DESCRIPTION']
          verify_options[:provider_state] = ENV['PACT_PROVIDER_STATE'] if ENV['PACT_PROVIDER_STATE']

          Cli::RunPactVerification.call(verify_options)
        rescue SystemExit => e
          e.status
        end
      end

      def require_pact_project_pact_helper
        require ENV['PACT_PROJECT_PACT_HELPER'] if ENV.fetch('PACT_PROJECT_PACT_HELPER','') != ''
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
