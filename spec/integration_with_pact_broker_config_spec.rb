require 'pact/provider_verifier/cli/verify'

describe "pact-provider-verifier with pact broker config" do
  before do
    allow(pact_broker_api).to receive(:fetch_pact_uris_for_verification).and_return(pact_uris)
    allow(pact_broker_api).to receive(:build_pact_uri) { | url | OpenStruct.new(uri: url) }
    allow(Pact::Cli::RunPactVerification).to receive(:call)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('PACT_INCLUDE_PENDING').and_return('true')
  end

  let(:args) do
    %W{pact-provider-verifier
      --provider Foo
      --consumer-version-tag master
      --consumer-version-tag prod
      --provider-version-tag pmaster
      --pact-broker-base-url http://localhost:5738
      --broker-token token
      --provider-base-url http://localhost:4567}
  end
  let(:pact_uris) { ["http://pact"] }
  let(:pact_broker_api) { class_double(Pact::PactBroker).as_stubbed_const }

  subject do
    begin
      Pact::ProviderVerifier::CLI::Verify.start(args)
    rescue SystemExit
      # otherwise, we'll exit rspec
    end
  end

  it "fetches the pact URIs from the broker" do
    expect(pact_broker_api).to receive(:fetch_pact_uris_for_verification).with(
      "Foo",
      [{ tag: "master", latest: true }, { tag: "prod", latest: true }],
      ["pmaster"],
      "http://localhost:5738",
      { username: nil, password: nil, token: "token", verbose: nil },
      { include_pending_status: false }
    )
    subject
  end

  it "verifies the pact" do
    expect(Pact::Cli::RunPactVerification).to receive(:call).with(hash_including(pact_uri: "http://pact"))
    subject
  end
end
