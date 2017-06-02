require 'faraday'

module Pact
  module ProviderVerifier

    class SetUpProviderStateError < StandardError; end

    class SetUpProviderState

      def initialize provider_state, consumer, options
        @provider_state = provider_state
        @consumer = consumer
        @options = options
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

      attr_reader :provider_state, :consumer

      def post_to_provider_state
        connection = Faraday.new(:url => provider_states_setup_url)
        connection.post do |req|
          req.headers["Content-Type"] = "application/json"
          req.body = {consumer: consumer, state: provider_state, states: [provider_state] }.to_json
        end
      end

      def provider_states_setup_url
        ENV['PROVIDER_STATES_SETUP_URL']
      end

      def verbose?
        ENV['VERBOSE_LOGGING']
      end

      def check_for_error response
        if response.status >= 300
          raise SetUpProviderStateError.new("Error setting up provider state '#{provider_state}' for consumer '#{consumer}' at #{provider_states_setup_url}. response status=#{response.status} response body=#{response.body}")
        end
      end

      def log_request
        if verbose?
          $stdout.puts "DEBUG: Setting up provider state '#{provider_state}' for consumer '#{consumer}' using provider state server at #{provider_states_setup_url}"
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
