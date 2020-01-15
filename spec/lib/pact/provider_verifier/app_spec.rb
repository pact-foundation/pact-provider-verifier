require 'pact/provider_verifier/app'

module Pact
  module ProviderVerifier
    describe App do
      describe "call" do
        before do
          allow(AggregatePactConfigs).to receive(:call).and_return([])
          allow(Cli::RunPactVerification).to receive(:call)
          allow(Pact).to receive(:clear_configuration)
          allow(Pact).to receive(:clear_consumer_world)
          allow(Pact).to receive(:clear_provider_world)
          allow_any_instance_of(App).to receive(:wait_until_server_available).and_return(true)
          allow($stderr).to receive(:puts)
          allow(Git).to receive(:branch)
        end

        let(:options) do
          double('options',
            provider_base_url: "http://provider",
            provider_version_tag: ["foo"],
            wait: 1,
            provider_states_url: nil
            ).as_null_object
        end

        let(:pact_urls) { ["http://pact"] }

        subject { App.call(pact_urls, options) }

        context "when tag_with_git_branch is true" do
          before do
            allow(Git).to receive(:branch).and_return("master")
          end
          it "merges the git branch with any specified provider tags" do
            # This is a shitty way to test the provider tags, but it's easier than checking
            # that the pact configuration DSL is called the right way!
            expect(AggregatePactConfigs).to receive(:call).with(
              anything,
              anything,
              anything,
              anything,
              ["foo", "master"],
              anything,
              anything,
              anything
            )
            subject
          end
        end
      end
    end
  end
end
