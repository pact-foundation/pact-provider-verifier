require 'support/provider_with_self_signed_cert'
require 'find_a_port'

describe "verifying a provider that uses a self signed certificate" do

  before(:all) do
    @port = FindAPort.available_port
    @ssl_server_pid = fork do
      run_provider_with_self_signed_cert @port
    end
    sleep 2
  end

  subject { `bundle exec bin/pact-provider-verifier -a 1.0.0 --provider-base-url https://localhost:#{@port} --pact-urls ./test/me-they.json --provider_states_setup_url https://localhost:#{@port}/provider-state -v` }

  it "passes because it has SSL verification turned off" do
    expect(subject).to include "2 interactions, 0 failures"
  end

  after(:all) do
    Process.kill('KILL', @ssl_server_pid)
  end
end
