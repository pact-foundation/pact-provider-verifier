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
    end
  end
end
