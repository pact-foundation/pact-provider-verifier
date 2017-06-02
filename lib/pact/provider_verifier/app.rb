require 'pact/provider/proxy/tasks'
require 'pact/provider/proxy'
require 'pact/provider/rspec'
require 'rack/reverse_proxy'
require 'pact/cli/run_pact_verification'
require 'net/https'
require 'faraday_middleware'
require 'json'

module Pact
  module ProviderVerifier

    def self.new *args
      App.new(*args)
    end

    class App
      def initialize options = {}
        @options = options
      end

      def call env
        @app.call env
      end

      def to_s
        "#{@name} #{super.to_s}"
      end

      def verify_pacts
        print_deprecation_note
        pacts = @options.pact_urls.split(',')
        proxy_pact_helper = File.expand_path(File.join(File.dirname(__FILE__), "pact_helper.rb"))
        ENV['PROVIDER_STATES_SETUP_URL'] = @options.provider_states_setup_url
        ENV['VERBOSE_LOGGING'] = @options.verbose if @options.verbose
        provider_base_url = @options.provider_base_url

        provider_application_version = @options.provider_app_version
        publish_results  = @options.publish_verification_results

        Pact.service_provider "Running Provider Application" do
          app do
            Rack::ReverseProxy.new do
              reverse_proxy '/', provider_base_url
            end
          end

          if provider_application_version
            app_version provider_application_version
          end

          publish_verification_results publish_results
        end

        require ENV['PACT_PROJECT_PACT_HELPER'] if ENV.fetch('PACT_PROJECT_PACT_HELPER','') != ''

        exit_statuses = pacts.collect do |pact_url|
          begin
            options = {
              :pact_helper => proxy_pact_helper,
              :pact_uri => pact_url,
              :backtrace => false,
              :pact_broker_username => @options.broker_username,
              :pact_broker_password => @options.broker_password
            }
            Cli::RunPactVerification.call(options)
          rescue SystemExit => e
            puts ""
            e.status
          end
        end

        # Return non-zero exit code if failures - increment for each Pact
        exit exit_statuses.count{ | status | status != 0 }
      end

      def print_deprecation_note
        if @options.provider_states_url
          $stderr.puts "The --provider-states-url option is deprecated and the URL endpoint can be removed from the application"
        end
      end
    end
  end
end
