require 'delegate'

module Pact
  module ProviderVerifier
    module ProviderStates
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

      class AddProviderStatesHeader

        def self.call(request, interaction)
          if interaction.provider_state
            extra_rack_headers = {
              "X_PACT_PROVIDER_STATES" => [{ "name" => interaction.provider_state }]
            }
            RequestDelegate.new(request, extra_rack_headers)
          else
            request
          end
        end
      end
    end
  end
end
