require 'thor'
require 'pact/provider_verifier/cli/custom_thor'

module Pact
  module ProviderVerifier
    module CLI
      class Verify < CustomThor

        class InvalidArgumentsError < ::Thor::Error; end
        class AuthError < ::Thor::Error; end

        desc 'PACT_URL ...', "Verify pact(s) against a provider. Supports local and networked (http-based) files."
        long_desc File.read(File.join(File.dirname(__FILE__), 'long_desc.txt')).gsub("\n", "\x5")
        method_option :provider_base_url, aliases: "-h", desc: "Provider host URL", :required => true
        method_option :provider_states_setup_url, aliases: "-c", desc: "Base URL to setup the provider states at", :required => false
        method_option :pact_broker_base_url, desc: "Base URL of the Pact Broker from which to retrieve the pacts. Can also be set using the environment variable PACT_BROKER_BASE_URL.", :required => false
        method_option :broker_username, aliases: "-n", desc: "Pact Broker basic auth username. Can also be set using the environment variable PACT_BROKER_USERNAME.", :required => false
        method_option :broker_password, aliases: "-p", desc: "Pact Broker basic auth password. Can also be set using the environment variable PACT_BROKER_PASSWORD.", :required => false
        method_option :broker_token, aliases: "-k", desc: "Pact Broker bearer token. Can also be set using the environment variable PACT_BROKER_TOKEN.", :required => false
        method_option :provider, required: false
        method_option :consumer_version_tag, type: :array, banner: "TAG", desc: "Retrieve the latest pacts with this consumer version tag. Used in conjunction with --provider. May be specified multiple times.", :required => false
        method_option :consumer_version_selector, hide: true, type: :array, banner: "SELECTOR", desc: "JSON string specifying a selector that identifies which pacts to verify. May be specified multiple times. See below for further documentation.", :required => false
        method_option :provider_version_tag, type: :array, banner: "TAG", desc: "Tag to apply to the provider application version. May be specified multiple times.", :required => false
        method_option :provider_version_branch, banner: "BRANCH", desc: "The name of the branch the provider version belongs to.", :required => false
        method_option :tag_with_git_branch, aliases: "-g", type: :boolean, default: false, required: false, desc: "Tag provider version with the name of the current git branch. Default: false"
        method_option :provider_app_version, aliases: "-a", desc: "Provider application version, required when publishing verification results", :required => false
        method_option :publish_verification_results, aliases: "-r", desc: "Publish verification results to the broker. This can also be enabled by setting the environment variable PACT_BROKER_PUBLISH_VERIFICATION_RESULTS=true", required: false, type: :boolean, default: false
        method_option :enable_pending, desc: "Allow pacts which are in pending state to be verified without causing the overall task to fail. For more information, see https://pact.io/pending", required: false, type: :boolean, default: false
        method_option :include_wip_pacts_since, desc: "", hide: true
        method_option :custom_provider_header, type: :array, banner: 'CUSTOM_PROVIDER_HEADER', desc: "Header to add to provider state set up and pact verification requests. eg 'Authorization: Basic cGFjdDpwYWN0'. May be specified multiple times.", :required => false
        method_option :custom_middleware, type: :array, banner: 'FILE', desc: "Ruby file containing a class implementing Pact::ProviderVerifier::CustomMiddleware. This allows the response to be modified before replaying. Use with caution!", :required => false
        method_option :monkeypatch, hide: true, type: :array, :required => false
        method_option :verbose, aliases: "-v", desc: "Verbose output. Can also be set by setting the environment variable VERBOSE=true.", :required => false
        method_option :provider_states_url, aliases: "-s", :required => false, hide: true
        method_option :format, banner: "FORMATTER", aliases: "-f", desc: "RSpec formatter. Defaults to custom Pact formatter. Other options are json and RspecJunitFormatter (which outputs xml)."
        method_option :out, aliases: "-o", banner: "FILE", desc: "Write output to a file instead of $stdout."
        method_option :ignore_failures, type: :boolean, default: false, desc: "If specified, process will always exit with exit code 0", hide: true
        method_option :pact_urls, aliases: "-u", hide: true, :required => false
        method_option :wait, banner: "SECONDS", required: false, type: :numeric, desc: "The number of seconds to poll for the provider to become available before running the verification", default: 0
        method_option :log_dir, desc: "The directory for the pact.log file"
        method_option :log_level, desc: "The log level", default: "debug"
        method_option :fail_if_no_pacts_found, desc: "If specified, will fail when no pacts are found", required: false, type: :boolean, default: false

        def verify(*pact_urls)
          require 'pact/provider_verifier/app'
          require 'socket'
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
            validate_consumer_version_selectors
            validate_wip_since_date
            validate_credentials
            validate_log_level
          end

          def validate_credentials
            if (options.broker_username || ENV['PACT_BROKER_USERNAME']) && (options.broker_token || ENV['PACT_BROKER_TOKEN'])
              raise AuthError, "You cannot provide both a username/password and a bearer token. If your Pact Broker uses a bearer token, please remove the username and password configuration."
            end
          end

          def validate_wip_since_date
            require 'date'

            if options.include_wip_pacts_since
              begin
                DateTime.parse(options.include_wip_pacts_since)
              rescue ArgumentError
                raise InvalidArgumentsError, "The value provided for --include-wip-pacts-since could not be parsed to a DateTime. Please provide a value in the format %Y-%m-%d or %Y-%m-%dT%H:%M:%S.000%:z"
              end
            end
          end

          def validate_consumer_version_selectors
            error_messages = (options.consumer_version_selector || []).collect do | string |
              begin
                JSON.parse(string)
                nil
              rescue
                "Invalid JSON string provided for --consumer-version-selector: #{string}"
              end
            end.compact

            if error_messages.any?
              raise InvalidArgumentsError, error_messages.join("\n")
            end
          end

          def validate_log_level
            if options.log_level
              valid_log_levels = %w{debug info warn error fatal}
              if !valid_log_levels.include?(options.log_level.downcase)
                raise InvalidArgumentsError, "Invalid log level '#{options.log_level}'. Must be one of: #{valid_log_levels.join(", ")}."
              end
            end
          end

          def exit_with_non_zero_status
            exit 1
          end

          def self.exit_on_failure?
            true
          end
        end
      end
    end
  end
end
