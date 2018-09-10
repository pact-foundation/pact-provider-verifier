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

        let(:pending_pact_uris) { ["http://pact-2", "http://pact-3"] }
        let(:pact_broker_api) { class_double(Pact::PactBroker).as_stubbed_const }

        subject { AggregatePactConfigs.call(pact_urls, provider_name, consumer_version_tags, pact_broker_base_url, http_client_options) }

        context "with no broker config" do
          let(:pact_broker_base_url) { nil }

          it "does not make a call to a Pact Broker" do
            expect(pact_broker_api).to_not receive(:fetch_pact_uris)
            subject
          end

          it "returns the hardcoded urls" do
            expect(subject).to eq [OpenStruct.new(uri: "http://pact-1")]
          end
        end

        context "with broker config" do
          before do
            allow(pact_broker_api).to receive(:fetch_pact_uris).and_return(pact_uris)
            allow(pact_broker_api).to receive(:fetch_pending_pact_uris).and_return(pending_pact_uris)
          end

          it "fetches the non pending pacts" do
            expect(pact_broker_api).to receive(:fetch_pact_uris).with(provider_name, consumer_version_tags, pact_broker_base_url, http_client_options)
            subject
          end

          context "when env var PACT_INCLUDE_PENDING is not 'true'" do
            it "does not fetch the pending pacts" do
              expect(pact_broker_api).to_not receive(:fetch_pending_pact_uris)
              subject
            end

            it "returns the non pending urls first" do
              expect(subject.first).to eq OpenStruct.new(uri: "http://pact-2")
            end

            it "returns the hardcoded urls last" do
              expect(subject.last).to eq OpenStruct.new(uri: "http://pact-1")
            end
          end

          context "when env var PACT_INCLUDE_PENDING is 'true'" do
            before do
              allow(ENV).to receive(:[]).and_call_original
              allow(ENV).to receive(:[]).with('PACT_INCLUDE_PENDING').and_return('true')
            end

            it "fetches the pending pacts" do
              expect(pact_broker_api).to receive(:fetch_pending_pact_uris).with(provider_name, pact_broker_base_url, http_client_options)
              subject
            end

            it "returns the pending urls first, with the non-pending pact URLs removed" do
              expect(subject.first).to eq OpenStruct.new(uri: "http://pact-3", pending: true)
            end

            it "returns the non pending urls next" do
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
end
