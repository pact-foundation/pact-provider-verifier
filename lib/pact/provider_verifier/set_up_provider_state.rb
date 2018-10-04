require 'faraday'

module Pact
  module ProviderVerifier

    class SetUpProviderStateError < StandardError; end

    class SetUpProviderState

      def initialize provider_state, consumer, options
        @provider_state = provider_state
        @consumer = consumer
        @options = options
        @params = (options && options[:params]) || {}
      end

      def self.call provider_state, consumer, options
        new(provider_state, consumer, options).call
      end

      def call
        if provider_states_setup_url.nil?
          warn_if_provider_state_set
          return
        end

        log_request
        response = post_to_provider_state
        check_for_error response
      end

      private

      attr_reader :provider_state, :consumer, :params

      def post_to_provider_state
        verbose = verbose?
        options = {url: provider_states_setup_url}

        if provider_states_setup_url.start_with?("https:")
          options[:ssl] = {verify: false}
        end

        connection = Faraday.new(options) do | faraday |
          # Have encountered flakiness on windows build for pact-go
          # Using retries as a hacky solution to try and get around this
          # until/if we can work out what the underlying cause is.
          # https://github.com/pact-foundation/pact-go/issues/42
          # eg. https://ci.appveyor.com/project/mefellows/pact-go/build/25#L1202

          faraday.request :retry, max: 2, interval: 0.05,
            interval_randomness: 0.5, backoff_factor: 2,
            methods:[:post],
            exceptions: [Faraday::ConnectionFailed]

          faraday.response :logger if verbose
          faraday.adapter Faraday.default_adapter
        end

        connection.post do |req|
          req.headers["Content-Type"] = "application/json"
          add_custom_provider_header req
          req.body = {
            consumer: consumer,
            state: provider_state,
            states: [provider_state],
            params: params
          }.to_json
        end
      end

      def provider_states_setup_url
        ENV['PROVIDER_STATES_SETUP_URL']
      end

      def verbose?
        ENV['VERBOSE_LOGGING']
      end

      def custom_provider_headers
        ENV.fetch('CUSTOM_PROVIDER_HEADER', '').split("\n").each_with_object({}) do | header, headers_hash |
          header_name, header_value = header.split(":", 2).collect(&:strip)
          headers_hash[header_name] = header_value
        end
      end

      def add_custom_provider_header request
        custom_provider_headers.each do | header_name, header_value |
          request[header_name] = header_value
        end
      end

      def check_for_error response
        if response.status >= 300
          raise SetUpProviderStateError.new("Error setting up provider state '#{provider_state}' for consumer '#{consumer}' at #{provider_states_setup_url}. response status=#{response.status} response body=#{response.body}")
        end
      end

      def log_request
        if verbose?
          $stdout.puts "DEBUG: Setting up provider state '#{provider_state}' for consumer '#{consumer}' using provider state set up URL #{provider_states_setup_url}"
        end
      end

      def warn_if_provider_state_set
        if provider_state
          $stderr.puts "WARN: Skipping set up for provider state '#{provider_state}' for consumer '#{consumer}' as there is no --provider-states-setup-url specified."
        end
      end
    end
  end
end
