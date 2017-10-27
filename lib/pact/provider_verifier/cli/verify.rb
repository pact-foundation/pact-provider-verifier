require 'thor'
require 'socket'
require 'pact/provider_verifier/app'
require 'pact/provider_verifier/cli/custom_thor'

module Pact
  module ProviderVerifier
    module CLI
      class Verify < CustomThor
        desc 'PACT_URL ...', "Verify pact(s) against a provider. Supports local and networked (http-based) files."
        method_option :provider_base_url, aliases: "-h", desc: "Provider host URL", :required => true
        method_option :provider_states_setup_url, aliases: "-c", desc: "Base URL to setup the provider states at", :required => false
        method_option :provider_app_version, aliases: "-a", desc: "Provider application version, required when publishing verification results", :required => false
        method_option :publish_verification_results, aliases: "-r", desc: "Publish verification results to the broker", required: false
        method_option :broker_username, aliases: "-n", desc: "Pact Broker basic auth username", :required => false
        method_option :broker_password, aliases: "-p", desc: "Pact Broker basic auth password", :required => false
        method_option :custom_provider_header, type: :array, banner: 'CUSTOM_PROVIDER_HEADER', desc: "Header to add to provider state set up and pact verification requests. eg 'Authorization: Basic cGFjdDpwYWN0'. May be specified multiple times.", :required => false
        method_option :verbose, aliases: "-v", desc: "Verbose output", :required => false
        method_option :provider_states_url, aliases: "-s", :required => false, hide: true
        method_option :format, banner: "FORMATTER", aliases: "-f", desc: "RSpec formatter. Defaults to custom Pact formatter. [j]son may also be used."
        method_option :pact_urls, aliases: "-u", desc: "DEPRECATED. Please provide as space separated arguments.", :required => false

        def verify(*pact_urls)
          print_deprecation_warnings
          Pact::ProviderVerifier::App.call(merged_urls(pact_urls), options)
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
        end
      end
    end
  end
end
