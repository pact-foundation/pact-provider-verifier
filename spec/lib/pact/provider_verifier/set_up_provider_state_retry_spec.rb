require 'pact/provider_verifier/set_up_provider_state'
require 'json'
require 'webmock/rspec'

module Pact
  module ProviderVerifier
    describe SetUpProviderState do
      let(:provider_states_setup_url) { 'http://localhost:2000' }
      let(:provider_state) { 'some state' }
      let(:consumer) { 'Foo' }
      let(:options) { {} }

      subject { SetUpProviderState.call(provider_state, consumer, options) }

      before do
        ENV['PROVIDER_STATES_SETUP_URL'] = provider_states_setup_url
        stub_request(:any, 'http://localhost:2000').to_raise(Errno::ECONNRESET.new).times(2)
          .then.to_return(status: 200)
      end

      it "makes a HTTP request to the configured URL with a JSON body containing the consumer and provider state names" do
        subject
      end
    end
  end
end
