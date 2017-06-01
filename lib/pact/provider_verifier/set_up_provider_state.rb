module Pact
  module ProviderVerifier

    class SetUpProviderStateError < StandardError; end

    class SetUpProviderState

      def self.call provider_state, consumer, options
        if verbose?
          puts "Setting up provider state '#{provider_state}' for consumer '#{consumer}' using provider state server at #{provider_states_setup_url}"
        end

        conn = Faraday.new(:url => provider_states_setup_url) do |faraday|
          if ENV['PACT_BROKER_USERNAME'] && ENV['PACT_BROKER_PASSWORD']
            faraday.use Faraday::Request::BasicAuthentication, ENV['PACT_BROKER_USERNAME'], ENV['PACT_BROKER_PASSWORD']
          end
          faraday.adapter  Faraday.default_adapter
        end
        response = conn.post do |req|
          req.headers["Content-Type"] = "application/json"
          req.body = {consumer: consumer, state: provider_state }.to_json
        end

        # Not sure about this?
        if response.status >= 300
          raise SetUpProviderStateError.new("Error setting up provider state '#{provider_state}' for consumer '#{consumer}' at #{provider_states_setup_url}. response status=#{response.status} response.body=#{response.body}")
        end

      end

      def self.provider_states_setup_url
        ENV['provider_states_setup_url']
      end

      def self.verbose?
        ENV['VERBOSE_LOGGING']
      end
    end
  end
end
