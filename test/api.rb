require 'sinatra'
require 'sinatra/base'
require 'sinatra/json'
require 'json'

state_data = ""

def get_provider_state request
  JSON.parse(request.body.read)["state"]
end


get '/' do
  json :greeting => 'Hello'
end

get '/fail' do
  json :greeting => 'Oh noes!'
end

post '/provider-state' do

  if get_provider_state(request) == "There is a greeting"
    state_data = "State data!"
  end

  status 201
end

get '/somestate' do
  json :greeting => state_data
end
