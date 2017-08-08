require_relative 'provider'

if ENV['USE_BASIC_AUTH'] == 'true'
  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    username == 'pact' and password == 'pact'
  end
end

run Provider
