require 'pact/provider_verifier/app'

RSpec.describe "verifying a message pact" do

  before(:all) do
    @pipe = IO.popen("rackup -p 9393 spec/support/message_producer_verifier.ru")
    sleep 2
  end

  let(:pact_path) { './spec/support/pacts/message-pact-v3-pass.json' }

  subject { `bundle exec bin/pact-provider-verifier #{pact_path}  -a 1.0.100 --provider-base-url http://localhost:9393 2>&1` }

  context "when verification passes" do
    it do
      expect(subject).to include("1 interaction, 0 failures")
    end
  end

  context "when verification fails" do
    let(:pact_path) { './spec/support/pacts/message-pact-v3-fail.json' }

    it do
      expect(subject).to include("1 interaction, 1 failure")
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
