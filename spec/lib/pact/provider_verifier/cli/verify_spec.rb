require 'pact/provider_verifier/cli/verify'
require 'ostruct'

module Pact
  module ProviderVerifier
    module CLI
      describe Verify do
        before do
          allow(Pact::ProviderVerifier::App).to receive(:call)
          subject.options = OpenStruct.new(minimum_valid_options)
        end

        let(:minimum_valid_options) do
          {
            provider_base_url: 'http://base'
          }
        end
        let(:pact_urls) { ['pact1.json', 'pact2.json'] }

        let(:invoke_verify) { subject.verify(*pact_urls) }

        it "invokes the verifier app with the given options" do
          expect(Pact::ProviderVerifier::App).to receive(:call).with(
            pact_urls, OpenStruct.new(minimum_valid_options))
          invoke_verify
        end

        context "when the deprecated pact-urls option is used" do
          before do
            allow($stderr).to receive(:puts)
            subject.options = OpenStruct.new(options)
          end

          let(:invoke_verify) { subject.verify }

          let(:options) do
            minimum_valid_options.merge(
              pact_urls: "pact1.json,pact2.json"
            )
          end

          it "splits them and invokes the verifier app" do
            expect(Pact::ProviderVerifier::App).to receive(:call).with(
              pact_urls, anything)
            invoke_verify
          end

          it "prints a deprecation warning" do
            expect($stderr).to receive(:puts).with(/WARN: The --pact-urls option is deprecated/)
            invoke_verify
          end
        end
      end
    end
  end
end
