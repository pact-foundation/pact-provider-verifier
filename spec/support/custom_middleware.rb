class AddCustomAuth < Pact::ProviderVerifier::CustomMiddleware

  def initialize app
    @app = app
  end

  def call env
    env['HTTP_AUTHORIZATION'] = 'Basic cGFjdDpwYWN0'
    @app.call(env)
  end
end
