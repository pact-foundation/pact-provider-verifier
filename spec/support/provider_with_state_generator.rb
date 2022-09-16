require 'sinatra'
require 'sinatra/base'
require 'sinatra/json'
require 'json'

class ProviderWithStateGenerator < Sinatra::Base
  post '/provider_state' do
    json :id => 2, :accessToken => 'INJECTED_TOKEN'
  end

  get '/book/1' do
    # Return 404 so that if the provider state is not injected the contract will fail
    status 404
    json :id => 1, :name => 'Book not found'
  end

  get '/book/2' do
    json :id => 2, :name => 'Injected Book'
  end

  get '/requires_auth' do
    if request.env['HTTP_AUTHORIZATION'] != "Bearer INJECTED_TOKEN"
      status 403
    end
  end

end
