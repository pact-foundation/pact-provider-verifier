require 'pact/provider_verifier/cli/verify'

describe "pact-provider-verifier with pact broker config" do
  before do
    allow(Pact::PactBroker).to receive(:fetch_pact_uris).and_return(pact_uris)
    allow(Pact::PactBroker).to receive(:fetch_wip_pact_uris).and_return(wip_pact_uris)
    allow(Pact::Cli::RunPactVerification).to receive(:call)
  end

  let(:args) { %W{pact-provider-verifier --provider Foo --consumer-version-tag master --consumer-version-tag prod --pact-broker-base-url http://localhost:5738 --broker-username username --broker-password password --provider-base-url http://localhost:4567} }
  let(:pact_uris) { ["http://non-wip-pact"] }
  let(:wip_pact_uris) { ["http://wip-pact"] }

  subject do
    begin
      Pact::ProviderVerifier::CLI::Verify.start(args)
    rescue SystemExit
      # otherwise, we'll exit rspec
    end
  end

  it "fetches the pact URIs from the broker" do
    expect(Pact::PactBroker).to receive(:fetch_pact_uris).with("Foo", ["master", "prod"], "http://localhost:5738", { username: "username", password: "password" })
    subject
  end

  it "fetches the WIP pact URIs from the broker" do
    expect(Pact::PactBroker).to receive(:fetch_wip_pact_uris).with("Foo", "http://localhost:5738", { username: "username", password: "password" })
    subject
  end

  it "verifies the non-wip pact" do
    expect(Pact::Cli::RunPactVerification).to receive(:call).with(hash_including(pact_uri: "http://non-wip-pact", wip: nil))
    subject
  end

  it "verifies the wip pact" do
    expect(Pact::Cli::RunPactVerification).to receive(:call).with(hash_including(pact_uri: "http://wip-pact", wip: true))
    subject
  end
end
