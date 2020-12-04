require 'delegate'

module Pact
  module ProviderVerifier
    class RequestDelegate < SimpleDelegator
      def initialize request, extra_rack_headers
        super(request)
        @extra_rack_headers = extra_rack_headers
      end

      def headers
        __getobj__().headers.merge(@extra_rack_headers)
      end

      def method
        __getobj__().method
      end
    end

    class AddInteractionAttributesHeader
      def self.call(request, interaction)
        extra_rack_headers = {
          "X_PACT_DESCRIPTION" => interaction.description
        }

        if interaction.provider_states
          extra_rack_headers["X_PACT_PROVIDER_STATES"] = interaction
            .provider_states.collect(&:to_hash)
        elsif interaction.provider_state
          extra_rack_headers["X_PACT_PROVIDER_STATES"] = [
            { "name" => interaction.provider_state }
          ]
        end

        RequestDelegate.new(request, extra_rack_headers)
      end
    end
  end
end
