describe "pact-provider-verifier with basic auth", skip_windows: true do
  before(:all) do
    @pipe = IO.popen({'USE_BASIC_AUTH' => 'true'}, %w{bundle exec rackup -p 4570 spec/support/config.ru})
    sleep 2
  end

  context "with --custom-provider-header specified" do

    subject { `bundle exec bin/pact-provider-verifier ./test/me-they.json --custom-provider-header "Foo: Bar" --custom-provider-header "Authorization: Basic cGFjdDpwYWN0" -a 1.0.100 --provider-base-url http://localhost:4570 --provider_states_setup_url http://localhost:4570/provider-state 2>&1` }

    it "exits with a 0 exit code" do
      subject
      puts subject
      expect($?).to eq 0
    end

    it "adds the headers" do
      expect(subject).to include "Adding header 'Foo: Bar'"
      expect(subject).to include "Adding header 'Authorization: Basic cGFjdDpwYWN0'"
    end

    it "the output contains a success message" do
      expect(subject).to include "2 interactions, 0 failures"
    end
  end

  after(:all) do
    Process.kill 'KILL', @pipe.pid
  end
end
