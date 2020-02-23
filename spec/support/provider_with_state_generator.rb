require 'sinatra'
require 'sinatra/base'
require 'sinatra/json'
require 'json'

class ProviderWithStateGenerator < Sinatra::Base
  post '/provider_state' do
    json :id => 2
  end

  get '/book/1' do
    json :id => 1, :name => 'Unexpected Book'
  end

  get '/book/2' do
    json :id => 2, :name => 'Injected Book'
  end
  
end
