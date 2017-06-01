describe "pact-provider-verifier" do
  before(:all) do
    @pipe = IO.popen("bundle exec rackup -p 4567 spec/support/config.ru")
    sleep 2
  end

  context "when the verification passes" do

    subject { `bundle exec bin/pact-provider-verifier -a 1.0.100 --provider-base-url http://localhost:4567 --pact-urls ./test/me-they.json --provider_states_setup_url http://localhost:4567/provider-state -v` }

    it "exits with a 0 exit code" do
      subject
      expect($?).to eq 0
    end

    it "the output contains a success message" do
      expect(subject).to include "2 interactions, 0 failures"
    end
  end

  context "with two passing pacts" do

    subject { `bundle exec bin/pact-provider-verifier -a 1.0.100 --provider-base-url http://localhost:4567 --pact-urls ./test/me-they.json,./test/another-they.json --provider_states_setup_url http://localhost:4567/provider-state -v` }
    it "exits with a 0 exit code" do
      expect($?).to eq 0
    end

    it "the output contains two success messages" do
      expect(subject.scan(/2 interactions, 0 failures/).size).to eq 2
    end
  end

  context "when the verification fails" do

    subject { `bundle exec bin/pact-provider-verifier -a 1.0.100 --provider-base-url http://localhost:4567 --pact-urls ./test/fail.json --provider_states_setup_url http://localhost:4567/provider-state -v` }

    it "exits with a non 0 exit code" do
      subject
      expect($?).to_not eq 0
    end

    it "the output contains an error message" do
      expect(subject).to include "interactions, 1 failure"
    end
  end

  context "when there is an error setting up the state" do

    subject { `bundle exec bin/pact-provider-verifier -a 1.0.100 --provider-base-url http://localhost:4567 --pact-urls ./test/me-they.json --provider_states_setup_url http://localhost:4567/wrong -v` }

    it "exits with a non 0 exit code" do
      subject
      expect($?).to_not eq 0
    end

    it "the output contains an error message" do
      expect(subject).to match /Error setting up provider state.*404/
    end
  end


  after(:all) do
    Process.kill 'TERM', @pipe.pid
  end
end
