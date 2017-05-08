require 'pact/provider/proxy/tasks'
require 'pact/provider/proxy'
require 'pact/provider/rspec'
require 'rack/reverse_proxy'
require 'pact/cli/run_pact_verification'
require 'net/https'
require 'faraday_middleware'
require 'json'

module Pact
  module ProviderVerifier

    def self.new *args
      App.new(*args)
    end

    class App
      def initialize options = {}
        @options = options
      end

      def call env
        @app.call env
      end

      def to_s
        "#{@name} #{super.to_s}"
      end

      def get_pact_consumer_name pact_url
        json = get_json(pact_url)
        json['consumer']['name']
      end

      def verify_pacts
        pacts = @options.pact_urls.split(',')
        proxy_pact_helper = File.expand_path(File.join(File.dirname(__FILE__), "pact_helper.rb"))
        ENV['provider_states_url'] = @options.provider_states_url
        ENV['provider_states_setup_url'] = @options.provider_states_setup_url
        ENV['PACT_BROKER_USERNAME'] = @options.broker_username if @options.broker_username
        ENV['PACT_BROKER_PASSWORD'] = @options.broker_password if @options.broker_password
        ENV['VERBOSE_LOGGING'] = @options.verbose if @options.verbose
        provider_base_url = @options.provider_base_url

        provider_application_version = @options.provider_app_version
        publish_results  = @options.publish_verification_results

        Pact.service_provider "Running Provider Application" do
          app do
            Rack::ReverseProxy.new do
              reverse_proxy '/', provider_base_url
            end
          end

          if provider_application_version
            app_version provider_application_version
          end

          publish_verification_results publish_results
        end

        require ENV['PACT_PROJECT_PACT_HELPER'] if ENV.fetch('PACT_PROJECT_PACT_HELPER','') != ''

        exit_statuses = pacts.collect do |pact_url|
          ENV['pact_consumer'] = get_pact_consumer_name(pact_url)

          begin
            options = {
              :pact_helper => proxy_pact_helper,
              :pact_uri => pact_url,
              :backtrace => false,
              :pact_broker_username => @options.broker_username,
              :pact_broker_password => @options.broker_password
            }
            Cli::RunPactVerification.call(options)
          rescue SystemExit => e
            puts ""
            e.status
          end
        end

        # Return non-zero exit code if failures - increment for each Pact
        exit exit_statuses.count{ | status | status != 0 }
      end
    end
  end
end

def get_json(path)
  case path
  when URI::regexp
    return get_json_from_server(path)
  else
    return get_json_from_local_file(path)
  end
end

def get_json_from_server(path)
  url = URI.parse(path)
  conn = Faraday.new("#{url.scheme}://#{url.host}:#{url.port}") do |c|
    if ENV['PACT_BROKER_USERNAME'] && ENV['PACT_BROKER_PASSWORD']
      c.use Faraday::Request::BasicAuthentication, ENV['PACT_BROKER_USERNAME'], ENV['PACT_BROKER_PASSWORD']
    end
    c.use FaradayMiddleware::ParseJson
    c.use Faraday::Adapter::NetHttp
  end

  response = conn.get(url.request_uri)
  return response.body
end

def get_json_from_local_file(path)
  file = File.read(path)
  return JSON.parse(file)
end
