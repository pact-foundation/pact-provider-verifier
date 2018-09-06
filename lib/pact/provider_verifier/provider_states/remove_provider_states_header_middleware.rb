module Pact
  module ProviderVerifier
    module ProviderStates
      class RemoveProviderStatesHeaderMiddleware
        def initialize app
          @app = app
        end

        def call env
          @app.call(remove_header(env))
        end

        def remove_header env
          env.reject { | key, value | key == "X_PACT_PROVIDER_STATES" }
        end
      end
    end
  end
end
