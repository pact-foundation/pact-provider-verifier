require 'pact/provider/proxy/tasks'
require 'pact/provider/proxy'
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
        require 'pp'
        pp options
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

        pacts.each do |pact_url|
            Pact::ProxyVerificationTask.new :"#{pact_url}" do | task |
                ENV['pact_consumer'] = get_pact_consumer_name(pact_url)
                task.pact_url pact_url, :pact_helper => proxy_pact_helper
                task.provider_base_url @options.provider_base_url
            end
            task_name = "pact:verify:#{pact_url}"
            Rake::Task[task_name].invoke
            Rake::Task[task_name].reenable
        end
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
  conn = Faraday.new("http://#{url.host}:#{url.port}") do |c|
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
