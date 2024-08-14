require 'json'
require 'fileutils'

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

  context "when there are multiple pacts to verify with --format json" do
    subject { `bundle exec bin/pact-provider-verifier ./test/me-they.json ./test/me-they.json --format json -a 1.0.100 --provider-base-url http://localhost:4567 --provider-states-setup-url http://localhost:4567/provider-state` }

    it "sends the results of both pacts to stdout" do
      expect(subject).to include "}\n{"
      expect(subject.scan(/\d examples, \d failure/).count).to eq 2
    end

    it "allows the results to be split and parsed to JSON" do
      result_1, result_2 = subject.split("\n", 2)
      JSON.parse(result_1)
      JSON.parse(result_2)
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
    if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
      env_vars = 'set PACT_DESCRIPTION="Provider state success" && set PACT_PROVIDER_STATE="There is a greeting" && '
    else
      env_vars = 'PACT_DESCRIPTION="Provider state success" PACT_PROVIDER_STATE="There is a greeting" '
    end
    subject { `#{env_vars}bundle exec bin/pact-provider-verifier ./test/me-they.json -a 1.0.100 --provider-base-url http://localhost:4567 --provider-states-setup-url http://localhost:4567/provider-state -v` }

    it "exits with a 0 exit code" do
      subject
      expect($?).to eq 0
    end

    it "the output contains a message indicating that the interactions have been filtered", skip_windows: true do
      expect(subject).to match /Filtering interactions by.*Provider state success.*There is a greeting/
    end
  end

  context "running verification with json output" do

    subject { `bundle exec bin/pact-provider-verifier ./test/me-they.json -a 1.0.100 --provider-base-url http://localhost:4567 --provider-states-setup-url http://localhost:4567/provider-state --format j` }

    it "exits with a 0 exit code" do
      puts subject
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

  context "running verification with json output to a file" do
    before do
      FileUtils.rm_rf 'tmp/out.json'
    end

    subject { `bundle exec bin/pact-provider-verifier ./test/me-they.json -a 1.0.100 --provider-base-url http://localhost:4567 --provider-states-setup-url http://localhost:4567/provider-state --format json --out tmp/out.json` }

    it "the json output is written to the file" do
      subject
      expect(JSON.parse(File.read('tmp/out.json'))).to be_a(Hash)
    end
  end

  context "setting a log dir" do
    before do
      FileUtils.rm_rf 'tmp/logs'
    end

    subject { `bundle exec bin/pact-provider-verifier ./test/me-they.json -a 1.0.100 --provider-base-url http://localhost:4567 --provider-states-setup-url http://localhost:4567/provider-state --log-dir tmp/logs --log-level info` }

    it "the logs are written at the right level" do
      subject
      expect(File.exist?('tmp/logs/pact.log'))
      logs = File.read('tmp/logs/pact.log')
      expect(logs).to include ('INFO')
      expect(logs).to_not include ('DEBUG')
    end
  end

  after(:all) do
    if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
      system("taskkill /im #{@pipe.pid}  /f /t >nul 2>&1")
    else
      Process.kill 'KILL', @pipe.pid
    end
  end
end
