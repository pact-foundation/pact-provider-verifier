require 'json'

describe "pact-provider-verifier with a prefix path in the base URL" do
  before(:all) do
    @pipe = IO.popen("bundle exec rackup -p 5837 spec/support/config_with_prefix.ru")
    sleep 2
  end

  subject { `bundle exec bin/pact-provider-verifier spec/support/pacts/prefix.json -a 1 --provider-base-url http://localhost:5837/prefix -v` }

  it "exits with a 0 exit code" do
    subject
    expect($?).to eq 0
  end

  it "the output contains a success message" do
    expect(subject).to include "1 interaction, 0 failures"
  end

  after(:all) do
    Process.kill 'KILL', @pipe.pid
  end
end
