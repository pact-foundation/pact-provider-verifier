require 'json'

describe "pact-provider-verifier" do
  before(:all) do
    @pipe = IO.popen("bundle exec rackup -p 4567 spec/support/config.ru")
    sleep 2
  end

  context "when the verification passes" do

    subject { `bundle exec bin/pact-provider-verifier ./test/me-they.json -a 1.0.100 --provider-base-url http://localhost:4567 --provider-states-setup-url http://localhost:4567/provider-state -v` }

    it "exits with a 0 exit code" do
      subject
      expect($?).to eq 0
    end

    it "the output contains a success message" do
      expect(subject).to include "2 interactions, 0 failures"
    end
  end

  context "with two passing interactions" do

    subject { `bundle exec bin/pact-provider-verifier ./test/me-they.json ./test/another-they.json -a 1.0.100 --provider-base-url http://localhost:4567 --provider-states-setup-url http://localhost:4567/provider-state -v` }
    it "exits with a 0 exit code" do
      expect($?).to eq 0
    end

    it "the output contains two success messages" do
      expect(subject.scan(/2 interactions, 0 failures/).size).to eq 2
    end
  end

  context "when the verification fails" do

    subject { `bundle exec bin/pact-provider-verifier ./test/fail.json -a 1.0.100 --provider-base-url http://localhost:4567 --provider-states-setup-url http://localhost:4567/provider-state -v` }

    it "exits with a non 0 exit code" do
      subject
      expect($?).to_not eq 0
    end

    it "the output contains an error message" do
      expect(subject).to include "interactions, 1 failure"
    end
  end

  context "when there is an error setting up the state" do

    subject { `bundle exec bin/pact-provider-verifier ./test/me-they.json -a 1.0.100 --provider-base-url http://localhost:4567 --provider-states-setup-url http://localhost:4567/wrong -v` }

    it "exits with a non 0 exit code" do
      subject
      expect($?).to_not eq 0
    end

    it "the output contains an error message" do
      expect(subject).to match /Error setting up provider state.*404/
    end
  end

  context "running verification with filtered interactions" do

    subject { `PACT_DESCRIPTION="Provider state success" PACT_PROVIDER_STATE="There is a greeting" bundle exec bin/pact-provider-verifier ./test/me-they.json -a 1.0.100 --provider-base-url http://localhost:4567 --provider-states-setup-url http://localhost:4567/provider-state -v` }

    it "exits with a 0 exit code" do
      subject
      expect($?).to eq 0
    end

    it "the output contains a message indicating that the interactions have been filtered" do
      expect(subject).to match /Filtering interactions by.*Provider state success.*There is a greeting/
    end
  end

  context "running verification with json output" do

    subject { `bundle exec bin/pact-provider-verifier ./test/me-they.json -a 1.0.100 --provider-base-url http://localhost:4567 --provider-states-setup-url http://localhost:4567/provider-state --format j` }

    it "exits with a 0 exit code" do
      subject
      expect($?).to eq 0
    end

    it "the output can be parsed to json" do
      expect(JSON.parse(subject)['examples'].size).to be > 1
    end
  end

  context "running verification with junit output" do

    subject { `bundle exec bin/pact-provider-verifier ./test/me-they.json -a 1.0.100 --provider-base-url http://localhost:4567 --provider-states-setup-url http://localhost:4567/provider-state --format RspecJunitFormatter` }

    it "exits with a 0 exit code" do
      subject
      expect($?).to eq 0
    end

    it "the output is xml" do
      expect(subject).to start_with '<?xml'
    end
  end

  after(:all) do
    Process.kill 'KILL', @pipe.pid
  end
end
