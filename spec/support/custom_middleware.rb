class AddCustomAuth < Pact::ProviderVerifier::CustomMiddleware
  def initialize app
    @app = app
  end

  def call env
    env['HTTP_AUTHORIZATION'] = 'Basic cGFjdDpwYWN0'
    provider_states = provider_states_from(env)
    provider_state_name = provider_states.any? && provider_states.first.name
    puts "The provider state name is '#{provider_state_name}'"
    @app.call(env)
  end
end
