require_relative 'provider'

def run_provider_with_self_signed_cert port
  trap 'INT' do @server.shutdown end
  require 'rack'
  require 'rack/handler/webrick'
  require 'webrick/https'

  webrick_opts = {:Port => port, :SSLEnable => true, :SSLCertName => [%w[CN localhost]]}
  Rack::Handler::WEBrick.run(Provider, webrick_opts) do |server|
    @server = server
  end
end

if __FILE__== $0
  run_provider_with_self_signed_cert 4568
end
