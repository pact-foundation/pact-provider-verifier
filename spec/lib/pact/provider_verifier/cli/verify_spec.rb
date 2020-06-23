require 'pact/provider_verifier/cli/verify'
require 'ostruct'

module Pact
  module ProviderVerifier
    module CLI
      describe Verify do
        before do
          allow(Pact::ProviderVerifier::App).to receive(:call).and_return(success)
          subject.options = OpenStruct.new(minimum_valid_options)
        end

        let(:success) { true }
        let(:ignore_failures) { 'ignore_failures' }
        let(:minimum_valid_options) do
          {
            provider_base_url: 'http://base',
            ignore_failures: ignore_failures
          }
        end
        let(:pact_urls) { ['pact1.json', 'pact2.json'] }

        let(:invoke_verify) { subject.verify(*pact_urls) }

        it "invokes the verifier app with the given options" do
          expect(Pact::ProviderVerifier::App).to receive(:call).with(
            pact_urls, OpenStruct.new(minimum_valid_options))
          invoke_verify
        end

        context "when --ignore-failures is not specified and App.call returns false" do
          let(:success) { false }
          let(:ignore_failures) { nil }

          it "exits with an error code" do
            begin
              invoke_verify
              fail "This line should not be executed"
            rescue SystemExit
            end
          end
        end

        context "with a pact broker config" do
          before do
            subject.options = OpenStruct.new(options)
          end

          let(:options) do
            minimum_valid_options.merge(
              pact_broker_base_url: "http://broker",
              provider: "Foo",
              consumer_version_tag: ["master", "prod"]
            )
          end

          it "invokes the verifier app with the given options" do
            expect(Pact::ProviderVerifier::App).to receive(:call).with(
              pact_urls, OpenStruct.new(options))
            invoke_verify
          end
        end

        context "with a pact broker URL but no provider name" do
          before do
            subject.options = OpenStruct.new(options)
          end

          let(:options) do
            minimum_valid_options.merge(
              pact_broker_base_url: "http://broker"
            )
          end

          it "raises an InvalidArgumentsError" do
            expect { subject.verify }.to raise_error Verify::InvalidArgumentsError
          end
        end

        context "when both basic auth credentials and bearer token are set" do
          before do
            subject.options = OpenStruct.new(options)
          end

          let(:options) do
            minimum_valid_options.merge(
              broker_username: "username",
              broker_token: "token"
            )
          end

          it "raises an error" do
            expect { invoke_verify }.to raise_error Verify::AuthError, /both/
          end
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

        context "with multiple --consumer-version-selector" do
          before do
            subject.options = OpenStruct.new(options)
          end

          let(:options) do
            minimum_valid_options.merge(
              pact_broker_base_url: "http://broker",
              provider: "Foo",
              consumer_version_selector: [ { tag: "master" }.to_json, { tag: "prod" }.to_json ]
            )
          end


          it "parses the JSON strings to hashes" do
            expect(Pact::ProviderVerifier::App).to receive(:call).with(
              pact_urls, OpenStruct.new(options))
            invoke_verify
          end
        end

        context "with --include-wip-pacts-since" do
          before do
            subject.options = OpenStruct.new(options)
          end

          context "with a valid date time" do
            let(:options) do
              minimum_valid_options.merge(
                include_wip_pacts_since: "2020-02-19T19:31:18.000+11:00"
              )
            end

            it "passes the argument to the app" do
              expect(Pact::ProviderVerifier::App).to receive(:call).with(
                pact_urls, OpenStruct.new(options))
              invoke_verify
            end
          end

          context "with an invalid date time" do
            let(:options) do
              minimum_valid_options.merge(
                include_wip_pacts_since: "foo"
              )
            end

            it "raises an error" do
              expect { invoke_verify }.to raise_error Verify::InvalidArgumentsError, /DateTime/
            end
          end


        end

        context "with --consumer-version-selector that is invalid JSON" do
          before do
            subject.options = OpenStruct.new(options)
          end

          let(:options) do
            minimum_valid_options.merge(
              pact_broker_base_url: "http://broker",
              provider: "Foo",
              consumer_version_selector: [ "a" ]
            )
          end

          it "raises an InvalidArgumentsError" do
            expect { subject.verify }.to raise_error Verify::InvalidArgumentsError, /Invalid JSON string/
          end
        end

        context "with an invalid log level" do
          before do
            subject.options = OpenStruct.new(options)
          end

          let(:options) do
            minimum_valid_options.merge(
              log_level: "foo"
            )
          end

          it "raises an InvalidArgumentsError" do
            expect { subject.verify }.to raise_error Verify::InvalidArgumentsError, "Invalid log level 'foo'. Must be one of: debug, info, warn, error, fatal."
          end
        end
      end
    end
  end
end
