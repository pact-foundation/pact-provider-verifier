require 'json'

describe "pact-provider-verifier with a provider state injected to a pact file" do
  before(:all) do
    @pipe = IO.popen("bundle exec rackup -p 5837 spec/support/provider_with_state_generator.rb")
    sleep 2
  end

  subject { `bundle exec bin/pact-provider-verifier spec/support/pacts/pact-with-provider-state.json -a 1 --provider-base-url http://localhost:5837/ --provider-states-setup-url http://localhost:5837/provider_state -v` }

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
