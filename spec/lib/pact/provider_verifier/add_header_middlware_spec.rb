require 'pact/provider_verifier/add_header_middlware'

module Pact
  module ProviderVerifier
    describe AddHeaderMiddlware do
      describe "call" do
        let(:target_app) { double(:app, call: nil) }
        let(:middlware) { AddHeaderMiddlware.new(target_app, headers) }
        let(:headers) { {'Foo-Bar' => 'foo'} }

        before do
          allow($stdout).to receive(:puts)
          allow($stderr).to receive(:puts)
        end

        it "keeps the existing headers" do
          expect(target_app).to receive(:call) do | env |
            expect(env['MOO']).to eq 'bar'
          end
          middlware.call('MOO' => 'bar')
        end

        it "adds the headers to the env" do
          expect(target_app).to receive(:call) do | env |
            expect(env['HTTP_FOO_BAR']).to eq 'foo'
          end
          middlware.call({'HTTP_FOO_BAR' => 'ick'})
        end

        context "when the specified header does not already exist" do
          it "warns the user" do
            expect($stderr).to receive(:puts).with(/WARN: Adding header 'Foo-Bar: foo'/)
            middlware.call({})
          end
        end

        context "when the specified header already exists" do
          it "notifies the user" do
            expect($stderr).to receive(:puts).with(/INFO: Replacing header 'Foo-Bar: wiffle' with 'Foo-Bar: foo'/)
            middlware.call({'HTTP_FOO_BAR' => 'wiffle' })
          end
        end
      end
    end
  end
end
