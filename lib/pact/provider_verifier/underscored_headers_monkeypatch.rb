# Ok, this doesn't make me feel good about myself, but it's the best way I've found
# to ensure that any underscored headers (eg "access_token") are not turned into dasherized
# headers by the Rack code that converts capitalized, dasherized headers into uppercase,
# underscored headers, and then back again.
# eg. access_token => HTTP_ACCESS_TOKEN => ACCESS-TOKEN
# To ensure the original header format is kept, an extra header, HTTP_X_PACT_ORIGINAL_HEADER_NAMES
# is added to the Rack Request when it is created from the request in the pact file, which contains
# a comma separated list of the original header names.
# This header is then removed by the modified Rack Reverse Proxy code, and used to restore
# the original header names if they have been transformed "incorrectly".
require 'pact/configuration'

def rack_reverse_proxy_headers_method_found
  begin
    RackReverseProxy::RoundTrip.instance_method(:headers)
    true
  rescue NameError
    Pact.configuration.error_stream.puts "WARN: Could not find the RackReverseProxy::RoundTrip#headers method. The implementation must have changed. Cannot monkey patch the aforementioned method to ensure any underscores are retained in header names. You can ignore this warning if you use normal dasherized headers."
    false
  end
end

def pact_provider_request_headers_method_found
  begin
    Pact::Provider::Request::Replayable.instance_method(:headers)
    true
  rescue NameError
    Pact.configuration.error_stream.puts "WARN: Could not find the Pact::Provider::Request::Replayable#headers method. The implementation must have changed. Cannot monkey patch the aforementioned method to ensure any underscores are retained in header names. You can ignore this warning if you use normal dasherized headers."
    false
  end
end

module Pact
  module ProviderVerifier
    module UnderscoredHeadersMonkeyPatch
      extend self

      def save_original_header_names rack_headers, expected_request_headers
        # expected_request_headers may be a Pact::NullExpectation
        if rack_headers.any?
          rack_headers['HTTP_X_PACT_ORIGINAL_HEADER_NAMES'] = expected_request_headers.keys.join(",")
        end
        rack_headers
      end

      def restore_original_header_names dasherized_headers
        original_header_names_value = dasherized_headers.delete("X-PACT-ORIGINAL-HEADER-NAMES")
        if original_header_names_value && original_header_names_value.size > 0
          replace_header_names(dasherized_headers, original_header_names_value.split(","))
        else
          dasherized_headers
        end
      end

      private

      def replace_header_names dasherized_headers, original_header_names
        original_header_names.each_with_object(dasherized_headers) do | original_header_name, headers |
          if headers.key?(pact_uppercase_and_dasherize(original_header_name))
            headers[original_header_name] = headers.delete(pact_uppercase_and_dasherize(original_header_name))
          end
        end
      end

      def pact_uppercase_and_dasherize header_name
        header_name.upcase.split("_").join("-")
      end
    end
  end
end

if pact_provider_request_headers_method_found && rack_reverse_proxy_headers_method_found
  module Pact
    module Provider
      module Request
        class Replayable
          alias_method :pact_old_headers, :headers

          def headers
            Pact::ProviderVerifier::UnderscoredHeadersMonkeyPatch.save_original_header_names(pact_old_headers, expected_request.headers)
          end
        end
      end
    end
  end

  module RackReverseProxy
    class RoundTrip
      alias_method :pact_old_headers, :headers

      def headers
        Pact::ProviderVerifier::UnderscoredHeadersMonkeyPatch.restore_original_header_names(pact_old_headers)
      end
    end
  end
end
