require 'pact/provider_verifier/aggregate_pact_configs'

module Pact
  module ProviderVerifier
    describe AggregatePactConfigs do
      describe ".call" do
        let(:pact_urls) { ["http://pact-1"] }
        let(:provider_name) { "Foo" }
        let(:consumer_version_tags) { ["master", "prod"] }
        let(:pact_broker_base_url) { "http://broker" }
        let(:http_client_options) { { "foo" => "bar"} }

        let(:pact_uris) { ["http://pact-2"] }

        let(:wip_pact_uris) { ["http://pact-2", "http://pact-3"] }

        subject { AggregatePactConfigs.call(pact_urls, provider_name, consumer_version_tags, pact_broker_base_url, http_client_options) }

        context "with no broker config" do
          let(:pact_broker_base_url) { nil }

          it "does not make a call to a Pact Broker" do
            expect(Pact::PactBroker).to_not receive(:fetch_pact_uris)
            subject
          end

          it "returns the hardcoded urls" do
            expect(subject).to eq [OpenStruct.new(uri: "http://pact-1")]
          end
        end

        context "with broker config" do
          before do
            allow(Pact::PactBroker).to receive(:fetch_pact_uris).and_return(pact_uris)
            allow(Pact::PactBroker).to receive(:fetch_wip_pact_uris).and_return(wip_pact_uris)
          end

          it "fetches the non wip pacts" do
            expect(Pact::PactBroker).to receive(:fetch_pact_uris).with(provider_name, consumer_version_tags, pact_broker_base_url, http_client_options)
            subject
          end

          it "fetches the wip pacts" do
            expect(Pact::PactBroker).to receive(:fetch_wip_pact_uris).with(provider_name, pact_broker_base_url, http_client_options)
            subject
          end

          it "returns the wip urls first, with the non-wip pact URLs removed" do
            expect(subject.first).to eq OpenStruct.new(uri: "http://pact-3", wip: true)
          end

          it "returns the wip urls next" do
            expect(subject[1]).to eq OpenStruct.new(uri: "http://pact-2")
          end

          it "returns the hardcoded urls last" do
            expect(subject.last).to eq OpenStruct.new(uri: "http://pact-1")
          end
        end
      end
    end
  end
end
