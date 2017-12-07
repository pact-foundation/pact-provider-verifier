require 'sinatra'
require 'sinatra/base'
require 'sinatra/json'
require 'json'

class Provider < Sinatra::Base
  get '/prefix/foo' do
    json :greeting => 'Hello'
  end
end
