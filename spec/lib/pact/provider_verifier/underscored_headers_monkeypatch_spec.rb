require 'pact/provider/request'
require 'rack/reverse_proxy'
require 'pact/provider_verifier/underscored_headers_monkeypatch'

module Pact
  module ProviderVerifier
    describe UnderscoredHeadersMonkeyPatch do
      describe "save_original_header_names" do
        let(:rack_headers) do
          {
            "HTTP_ACCESS_TOKEN" => "123",
            "HTTP_ACCEPT" => "application/json"
          }
        end

        let(:expected_request_headers) do
          {
            "access_token" => "123",
            "Accept" => "application/json"
          }
        end

        let(:expected_headers) do
          {
            "HTTP_ACCESS_TOKEN" => "123",
            "HTTP_ACCEPT" => "application/json",
            "HTTP_X_PACT_ORIGINAL_HEADER_NAMES" => "access_token,Accept"}
        end

        subject { UnderscoredHeadersMonkeyPatch.save_original_header_names(rack_headers, expected_request_headers) }

        it "sets the HTTP_X_PACT_ORIGINAL_HEADER_NAMES header, containing the original names of the headers defined in the pact" do
          expect(subject).to eq(expected_headers)
        end
      end

      describe "restore_original_header_names" do
        let(:dasherized_headers) do
          {
            "X-PACT-ORIGINAL-HEADER-NAMES" => "access_token,content-type",
            "ACCESS-TOKEN" => "123",
            "CONTENT-TYPE" => "foo"
          }
        end

        let(:expected_headers) do
          {
            "access_token" => "123",
            "content-type" => "foo"
          }
        end

        subject { UnderscoredHeadersMonkeyPatch.restore_original_header_names(dasherized_headers) }

        context "when X-PACT-ORIGINAL-HEADER-NAMES is present" do
          it "rremoves the X-PACT header and restores the original header names" do
            expect(subject).to eq(expected_headers)
          end
        end

        context "when X-PACT-ORIGINAL-HEADER-NAMES is present but empty" do
          let(:dasherized_headers) do
            {
              "X-PACT-ORIGINAL-HEADER-NAMES" => "",
              "ACCESS-TOKEN" => "123",
              "CONTENT-TYPE" => "foo"
            }
          end

          let(:expected_headers) do
            {
              "ACCESS-TOKEN" => "123",
              "CONTENT-TYPE" => "foo"
            }
          end

          it "removes the X-PACT header, but doesn't change the other headers" do
            expect(subject).to eq(expected_headers)
          end
        end

        context "when X-PACT-ORIGINAL-HEADER-NAMES is present but the names don't match for some bizarre reason" do
          let(:dasherized_headers) do
            {
              "X-PACT-ORIGINAL-HEADER-NAMES" => "foo",
              "ACCESS-TOKEN" => "123",
              "CONTENT-TYPE" => "foo"
            }
          end

          let(:expected_headers) do
            {
              "ACCESS-TOKEN" => "123",
              "CONTENT-TYPE" => "foo"
            }
          end

          it "removes the X-PACT header, but doesn't change the other headers" do
            expect(subject).to eq(expected_headers)
          end
        end

        context "when X-PACT-ORIGINAL-HEADER-NAMES is not present" do
          let(:dasherized_headers) do
            {
              "ACCESS-TOKEN" => "123",
              "CONTENT-TYPE" => "foo"
            }
          end

          let(:expected_headers) do
            {
              "ACCESS-TOKEN" => "123",
              "CONTENT-TYPE" => "foo"
            }
          end

          it "removes the X-PACT header, but doesn't change the other headers" do
            expect(subject).to eq(expected_headers)
          end
        end
      end
    end
  end
end


