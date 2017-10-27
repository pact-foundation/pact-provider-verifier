module Pact
  module ProviderVerifier
    class AddHeaderMiddlware

      def initialize app, headers
        @app = app
        @headers = headers
      end

      def call env
        @app.call(add_headers(env))
      end

      def add_headers env
        new_env = env.dup
        @headers.each_pair do | key, value |
          header_name = "HTTP_#{key.upcase.gsub("-", "_")}"
          warn_about_header_replacement key, new_env[header_name], value
          new_env[header_name] = value
        end
        new_env
      end

      def warn_about_header_replacement header_name, existing_value, new_value
        if existing_value.nil?
          $stderr.puts "WARN: Adding header '#{header_name}: #{new_value}' to replayed request. This header did not exist in the pact, and hence this test cannot confirm that the request will work in real life."
        else
          # Don't mess up the json formatter by using stdout here
          $stderr.puts "INFO: Replacing header '#{header_name}: #{existing_value}' with '#{header_name}: #{new_value}'"
        end
      end
    end
  end
end
