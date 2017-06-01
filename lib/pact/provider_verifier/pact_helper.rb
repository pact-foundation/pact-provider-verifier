require 'net/https'
require 'faraday_middleware'
require 'json'
require_relative './app'
require_relative 'set_up_provider_state'
require 'pact/provider/configuration'

# Responsible for making the call to the provider state server to set up the state

Pact.configure do | config |
  config.provider_state_set_up = Pact::ProviderVerifier::SetUpProviderState
  config.provider_state_tear_down = -> (*args){ }
end
