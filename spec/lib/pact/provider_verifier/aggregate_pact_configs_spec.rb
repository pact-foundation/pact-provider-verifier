require 'pact/provider_verifier/aggregate_pact_configs'

module Pact
  module ProviderVerifier
    describe AggregatePactConfigs do
      describe ".call" do

        let(:pact_urls) { ["http://pact-1"] }
        let(:provider_name) { "Foo" }
        let(:consumer_version_tags) { ["master", "prod"] }
        let(:provider_version_tags) { ["dev"] }
        let(:pact_broker_base_url) { "http://broker" }
        let(:http_client_options) { { "foo" => "bar"} }

        let(:pact_uris) { [double('PactURI', uri: "http://pact-2")] }
        let(:pending_pact_2) { double('PactURI', uri: "http://pact-2") }
        let(:pending_pact_3) { double('PactURI', uri: "http://pact-3") }
        let(:pending_pact_uris) { [pending_pact_2, pending_pact_3] }
        let(:pact_broker_api) { class_double(Pact::PactBroker).as_stubbed_const }

        before do
          # Trying to expose as little as possible of the class structure in the pact gem to pact-provider-verifier
          # This whole thing is a mess really!
          allow(pact_broker_api).to receive(:build_pact_uri) { | url | OpenStruct.new(uri: url) }
        end

        subject { AggregatePactConfigs.call(pact_urls, provider_name, consumer_version_tags, provider_version_tags, pact_broker_base_url, http_client_options) }

        context "with no broker config" do
          let(:pact_broker_base_url) { nil }

          it "does not make a call to a Pact Broker" do
            expect(pact_broker_api).to_not receive(:fetch_pacts_for_verification)
            subject
          end

          it "returns the hardcoded urls" do
            expect(subject).to eq [OpenStruct.new(uri: "http://pact-1")]
          end
        end

        context "with broker config" do
          before do
            allow(ENV).to receive(:[]).and_call_original
            allow(ENV).to receive(:[]).with('PACT_BROKER_PACTS_FOR_VERIFICATION_ENABLED').and_return('true')
            allow(pact_broker_api).to receive(:fetch_pacts_for_verification).and_return(pact_uris)
          end

          let(:metadata) { { some: 'metadata'} }
          let(:pact_uris) { [double('PactURI', uri: "http://pact-1", metadata: metadata)] }

          let(:consumer_version_selectors) do
            [{ tag: "master", latest: true }, { tag: "prod", latest: true }]
          end

          it "fetches the pacts for verification" do
            expect(pact_broker_api).to receive(:fetch_pacts_for_verification).with(provider_name, consumer_version_selectors, provider_version_tags, pact_broker_base_url, http_client_options)
            subject
          end

          it "returns a list of verification configs" do
            expect(subject.last).to eq OpenStruct.new(uri: "http://pact-1")
          end
        end
      end
    end
  end
end
