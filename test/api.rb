require 'sinatra'
require 'sinatra/base'
require 'sinatra/json'
require 'json'

state_data = ""

get '/' do
  json :greeting => 'Hello'
end

get '/fail' do
  json :greeting => 'Oh noes!'
end

get '/provider-states' do
  content_type :json
  {
    :me => ["There is a greeting"],
    :anotherclient => ["There is a greeting"]
  }.to_json
end

post '/provider-state' do
  logger.info "Provider state request: #{params}"
  state_data = "State data!"
  json :greeting => "State set"
  status 201
end

get '/somestate' do
  json :greeting => state_data
end
