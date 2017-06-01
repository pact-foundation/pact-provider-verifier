require 'sinatra'
require 'sinatra/base'
require 'sinatra/json'
require 'json'

$state_data = ""

class Provider < Sinatra::Base

  def initialize
    super
    @logger = Logger.new("./log/test.log")

    @logger.formatter = proc do |severity, datetime, progname, msg|
       "#{msg}\n"
    end
  end

  before do
    @body = request.body.read
    @logger.info "#{request.request_method} #{request.path} #{request.body.read} #{provider_state}"
  end

  after do
    @logger.info "#{response.status} #{response.body}"
  end

  error do
    e = env['sinatra.error']
    @logger.error "#{e.class} #{e.message} #{e.backtrace.join("\n")}"
    status 500
    {error: {class: e.class.to_s, message: e.message, backtrace: e.backtrace}}.to_json
  end

  def provider_state
    if @body.start_with?("{")
      JSON.parse(@body)["state"].tap { |it| @logger.info "Provider state is #{it}" }
    end
  end

  get '/' do
    json :greeting => 'Hello'
  end

  get '/fail' do
    json :greeting => 'Oh noes!'
  end

  post '/provider-state' do
    if provider_state == "There is a greeting"
      $state_data = "State data!"
      @logger.info "Setting $state_data to #{$state_data}"
    end

    status 201
  end

  get '/somestate' do
    json :greeting => $state_data
  end
end
