require 'net/https'
require 'faraday_middleware'
require 'json'
require_relative './app'
require_relative 'set_up_provider_state'
require 'pact/provider/configuration'
require 'pact/provider_verifier/underscored_headers_monkeypatch.rb'

# Responsible for making the call to the provider state server to set up the state

Pact.configure do | config |
  config.provider_state_set_up = Pact::ProviderVerifier::SetUpProviderState
  config.provider_state_tear_down = -> (*args){ }
end

if ENV['MONKEYPATCH']
  ENV['MONKEYPATCH'].split("\n").each do | file |
    $stdout.puts "DEBUG: Requiring monkeypatch file #{file}" if ENV['VERBOSE_LOGGING']
    begin
      require file
    rescue LoadError => e
      $stderr.puts "ERROR: #{e.class} - #{e.message}. Ensure you have specified the absolute path."
    end
  end
end
