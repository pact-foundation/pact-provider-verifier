module Pact
  module ProviderVerifier
    class RemoveInteractionAttributesHeaderMiddleware
      HEADERS_TO_REMOVE = %w[
        X_PACT_DESCRIPTION
        X_PACT_PROVIDER_STATES
      ]

      def initialize app
        @app = app
      end

      def call env
        @app.call(remove_header(env))
      end

      def remove_header env
        env.reject { | key, _ | HEADERS_TO_REMOVE.include?(key) }
      end
    end
  end
end
