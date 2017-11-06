require 'pact/provider_verifier/custom_middleware'

module Pact
  module ProviderVerifier
    describe CustomMiddleware do
      describe ".descendants" do

        class TestMiddlware < Pact::ProviderVerifier::CustomMiddleware

        end

        it "returns the TestMiddlware" do
          expect(CustomMiddleware.descendants).to eq [TestMiddlware]
        end
      end
    end
  end
end
