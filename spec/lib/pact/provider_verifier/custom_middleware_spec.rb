require 'pact/provider_verifier/custom_middleware'

module Pact
  module ProviderVerifier
    describe CustomMiddleware do
      describe ".descendants" do

        class TestMiddleware < Pact::ProviderVerifier::CustomMiddleware

        end

        it "returns the TestMiddleware" do
          expect(CustomMiddleware.descendants).to eq [TestMiddleware]
        end
      end

      describe "#provider_states_from" do

        subject { CustomMiddleware.new(nil).provider_states_from(env) }

        context "when the X_PACT_PROVIDER_STATES header exists" do
          let(:env) do
            {
              "X_PACT_PROVIDER_STATES" => [{
                "name" => "foo"
              }]
            }
          end

          it "returns an array of provider states" do
            expect(subject.first.name).to eq "foo"
          end
        end

        context "when the X_PACT_PROVIDER_STATES header does not exist" do
          let(:env) { {} }

          it "returns an empty array" do
            expect(subject).to eq []
          end
        end
      end
    end
  end
end
