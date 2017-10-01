describe "pact-provider-verifier" do
  before(:all) do
    @pipe = IO.popen("bundle exec rackup -p 4569 spec/support/provider-echo-host.ru")
    sleep 2
  end

  subject { `bundle exec bin/pact-provider-verifier ./spec/support/echo-host.json --provider-base-url http://localhost:4569` }

  it "sets the correct Host header" do
    expect(subject).to include "1 interaction, 0 failures"
  end

  after(:all) do
    Process.kill 'KILL', @pipe.pid
  end
end
