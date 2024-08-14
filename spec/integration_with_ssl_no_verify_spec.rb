require 'support/provider_with_self_signed_cert'
require 'find_a_port'

describe "verifying a provider that uses a self signed certificate" do

  before(:all) do
    @port = FindAPort.available_port
    @pipe =  IO.popen({}, %W{ruby spec/support/provider_with_self_signed_cert.rb #{@port}})
    sleep 2
  end
  it "passes because it has SSL verification turned off" do
    subject = `bundle exec bin/pact-provider-verifier ./test/me-they.json -a 1.0.0 --provider-base-url https://localhost:#{@port} --provider_states_setup_url https://localhost:#{@port}/provider-state -v`
    expect(subject).to include "2 interactions, 0 failures"
  end
  after(:all) do
    if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
      system("taskkill /im #{@pipe.pid}  /f /t >nul 2>&1")
    else
      Process.kill 'KILL', @pipe.pid
    end
  end
end
