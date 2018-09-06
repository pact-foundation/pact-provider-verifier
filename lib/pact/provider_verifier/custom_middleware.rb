require 'ostruct'

module Pact
  module ProviderVerifier
    class CustomMiddleware
      def self.descendants
        descendants = []
        ObjectSpace.each_object(singleton_class) do |k|
          descendants.unshift k unless k == self
        end
        descendants
      end

      attr_accessor :app

      def initialize app
        @app = app
      end

      def call env
        raise NotImplementedError
      end

      def provider_states_from(env)
        if env["X_PACT_PROVIDER_STATES"]
          env["X_PACT_PROVIDER_STATES"].collect{ | provider_state| OpenStruct.new(provider_state) }
        else
          []
        end
      end
    end
  end
end
