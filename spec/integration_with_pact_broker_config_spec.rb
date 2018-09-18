require 'pact/provider_verifier/cli/verify'

describe "pact-provider-verifier with pact broker config" do
  before do
    allow(pact_broker_api).to receive(:fetch_pact_uris).and_return(pact_uris)
    allow(pact_broker_api).to receive(:fetch_pending_pact_uris).and_return(pending_pact_uris)
    allow(Pact::Cli::RunPactVerification).to receive(:call)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('PACT_INCLUDE_PENDING').and_return('true')
  end

  let(:args) { %W{pact-provider-verifier --provider Foo --consumer-version-tag master --consumer-version-tag prod --pact-broker-base-url http://localhost:5738 --broker-username username --broker-password password --provider-base-url http://localhost:4567} }
  let(:pact_uris) { ["http://non-pending-pact"] }
  let(:pending_pact_uris) { ["http://pending-pact"] }
  let(:pact_broker_api) { class_double(Pact::PactBroker).as_stubbed_const }

  subject do
    begin
      Pact::ProviderVerifier::CLI::Verify.start(args)
    rescue SystemExit
      # otherwise, we'll exit rspec
    end
  end

  it "fetches the pact URIs from the broker" do
    expect(pact_broker_api).to receive(:fetch_pact_uris).with("Foo", ["master", "prod"], "http://localhost:5738", { username: "username", password: "password" })
    subject
  end

  it "fetches the pending pacts URIs from the broker" do
    expect(pact_broker_api).to receive(:fetch_pending_pact_uris).with("Foo", "http://localhost:5738", { username: "username", password: "password" })
    subject
  end

  it "verifies the non-pending pact" do
    expect(Pact::Cli::RunPactVerification).to receive(:call).with(hash_including(pact_uri: "http://non-pending-pact", ignore_failures: nil))
    subject
  end

  it "verifies the pending pact" do
    expect(Pact::Cli::RunPactVerification).to receive(:call).with(hash_including(pact_uri: "http://pending-pact", ignore_failures: true))
    subject
  end
end
