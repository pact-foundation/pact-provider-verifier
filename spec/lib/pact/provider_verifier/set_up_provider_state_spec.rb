require 'pact/provider_verifier/set_up_provider_state'
require 'webmock/rspec'

module Pact
  module ProviderVerifier

    describe SetUpProviderState do

      let(:provider_states_setup_url) { 'http://foo' }
      let(:provider_state) { 'some state' }
      let(:consumer) { 'Foo' }
      let(:options) { { params: params } }
      let(:params) { { "foo" => "bar" }}
      subject { SetUpProviderState.call(provider_state, consumer, options) }

      before do
        ENV['PROVIDER_STATES_SETUP_URL'] = provider_states_setup_url
        stub_request(:post, provider_states_setup_url).to_return(status: 200, body: '{"id":2}')
        allow($stdout).to receive(:puts)
        allow($stderr).to receive(:puts)
      end

      it "makes a HTTP request to the configured URL with a JSON body containing the consumer and provider state names" do
        expect(subject).to eq({"id" => 2})
        expect(WebMock).to have_requested(:post, provider_states_setup_url).
          with(body: {consumer: consumer, state: provider_state, states: [provider_state], params: params}, headers: {'Content-Type' => "application/json"})
      end

      context "when an error is returned from the request to the setup URL" do
        before do
          stub_request(:post, provider_states_setup_url).to_return(status: 500, body: "Some error")
        end

        context "when enable_pending is not set" do
          it "raises an error" do
            expect { subject }.to raise_error(SetUpProviderStateError, /500.*Some error/)
          end
        end

        context "when enable_pending is set" do
          let(:options) do
            {
              params: params,
              enable_pending: true,
            }
          end

          it "does not raise an error" do
            expect { subject }.not_to raise_error
          end
        end
      end

      context "when the provider_states_setup_url is nil" do
        before do
          ENV['PROVIDER_STATES_SETUP_URL'] = nil
        end

        it "does not make a HTTP request" do
          subject
          expect(WebMock).to_not have_requested(:post, provider_states_setup_url)
        end

        context "when a provider_state is present" do
          it "logs a warning" do
            expect($stderr).to receive(:puts).with("WARN: Skipping set up for provider state 'some state' for consumer 'Foo' as there is no --provider-states-setup-url specified.")
            subject
          end
        end

        context "when a provider_state is not present" do
          let(:provider_state) { nil }

          it "does not log a warning" do
            expect($stderr).to_not receive(:puts)
            subject
          end
        end
      end
    end
  end
end
