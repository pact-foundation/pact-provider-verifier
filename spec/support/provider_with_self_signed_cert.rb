require_relative 'provider'

def run_provider_with_self_signed_cert port
  # trap 'INT' do @server.shutdown end
  require 'rack'
  require_relative 'webbrick'
  require 'webrick/https'

  webrick_opts = {:Port => port, :SSLEnable => true, :SSLCertName => [%w[CN localhost]]}
  # https://www.rubydoc.info/gems/rack/2.2.6/Rack%2FHandler%2FWEBrick.run
  if RUBY_VERSION < "3"
    # To work with Ruby 2.7.0, this needs an explicit ruby2_keywords
    Rack::Handler::WEBrick.run(Provider, webrick_opts) do |server|
      @server = server
    end
  else
    Rack::Handler::WEBrick.run(Provider, **webrick_opts) do |server|
      @server = server
    end
  end
end

if __FILE__== $0
  port = ARGV[0] ? ARGV[0].to_i : 4568
  run_provider_with_self_signed_cert port
end
