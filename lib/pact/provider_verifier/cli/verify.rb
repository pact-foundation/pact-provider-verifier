require 'thor'
require 'socket'
require 'pact/provider_verifier/app'
require 'pact/provider_verifier/cli/custom_thor'

module Pact
  module ProviderVerifier
    module CLI
      class Verify < CustomThor

        class InvalidArgumentsError < ::Thor::Error; end

        desc 'PACT_URL ...', "Verify pact(s) against a provider. Supports local and networked (http-based) files."
        method_option :provider_base_url, aliases: "-h", desc: "Provider host URL", :required => true
        method_option :provider_states_setup_url, aliases: "-c", desc: "Base URL to setup the provider states at", :required => false
        method_option :pact_broker_base_url, desc: "Base URL of the Pact Broker from which to retrieve the pacts.", :required => false
        method_option :broker_username, aliases: "-n", desc: "Pact Broker basic auth username", :required => false
        method_option :broker_password, aliases: "-p", desc: "Pact Broker basic auth password", :required => false
        method_option :provider, required: false
        method_option :consumer_version_tag, type: :array, banner: "TAG", desc: "Retrieve the latest pacts with this consumer version tag. Used in conjunction with --provider. May be specified multiple times.", :required => false
        method_option :provider_app_version, aliases: "-a", desc: "Provider application version, required when publishing verification results", :required => false
        method_option :publish_verification_results, aliases: "-r", desc: "Publish verification results to the broker", required: false
        method_option :custom_provider_header, type: :array, banner: 'CUSTOM_PROVIDER_HEADER', desc: "Header to add to provider state set up and pact verification requests. eg 'Authorization: Basic cGFjdDpwYWN0'. May be specified multiple times.", :required => false
        method_option :custom_middleware, type: :array, banner: 'FILE', desc: "Ruby file containing a class implementing Pact::ProviderVerifier::CustomMiddleware. This allows the response to be modified before replaying. Use with caution!", :required => false
        method_option :monkeypatch, hide: true, type: :array, :required => false
        method_option :verbose, aliases: "-v", desc: "Verbose output", :required => false
        method_option :provider_states_url, aliases: "-s", :required => false, hide: true
        method_option :format, banner: "FORMATTER", aliases: "-f", desc: "RSpec formatter. Defaults to custom Pact formatter. Other options are json and RspecJunitFormatter (which outputs xml)."
        method_option :out, aliases: "-o", banner: "FILE", desc: "Write output to a file instead of $stdout."
        method_option :ignore_failures, type: :boolean, default: false, desc: "If specified, process will always exit with exit code 0", hide: true
        method_option :pact_urls, aliases: "-u", hide: true, :required => false

        def verify(*pact_urls)
          validate_verify
          print_deprecation_warnings
          success = Pact::ProviderVerifier::App.call(merged_urls(pact_urls), options)
          exit_with_non_zero_status if !success && !options.ignore_failures
        end

        default_task :verify

        desc 'version', 'Show the pact-provider-verifier gem version'
        def version
          require 'pact/provider_verifier/version'
          puts Pact::ProviderVerifier::VERSION
        end

        no_commands do
          def merged_urls pact_urls_from_args
            from_opts = options.pact_urls ? options.pact_urls.split(',') : []
            from_opts + pact_urls_from_args
          end

          def print_deprecation_warnings
            if options.pact_urls
              $stderr.puts "WARN: The --pact-urls option is deprecated. Please pass in a space separated list of URLs as the first arguments to the pact-provider-verifier command."
            end
          end

          def validate_verify
            if options.pact_broker_base_url && (options.provider.nil? || options.provider == "")
              raise InvalidArgumentsError, "No value provided for required option '--provider'"
            end
          end

          def exit_with_non_zero_status
            exit 1
          end

          def exit_on_failure?
            true
          end
        end
      end
    end
  end
end
