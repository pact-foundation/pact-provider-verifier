require 'find_a_port'

describe "pact-provider-verifier with an underscored header", skip_windows: true do
  before(:all) do
    @port = FindAPort.available_port
    @pipe = IO.popen({}, %W{ruby spec/support/provider_with_no_rack.rb #{@port}})
    sleep 2
  end

  subject { `bundle exec bin/pact-provider-verifier ./spec/support/pacts/underscored_header.json --provider-base-url http://localhost:#{@port} 2>&1` }

  it "exits with a 0 exit code" do
    subject
    puts subject
    expect($?).to eq 0
  end

  after(:all) do
    Process.kill 'KILL', @pipe.pid
  end
end
