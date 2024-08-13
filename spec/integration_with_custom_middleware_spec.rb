describe "pact-provider-verifier with basic auth" do
  before(:all) do
    @pipe = IO.popen({'USE_BASIC_AUTH' => 'true'}, %w{bundle exec rackup -p 4570 spec/support/config.ru})
    sleep 2
  end

  context "with --custom-middleware specified" do
    subject { `bundle exec bin/pact-provider-verifier spec/support/pacts/needs-custom-auth.json --custom-middleware #{Dir.pwd}/spec/support/custom_middleware.rb -a 1.0.100 --provider-base-url http://localhost:4570 -v 2>&1` }

    it "can modify the request" do
      subject
      expect($?).to eq 0
    end

    it "can access the provider state information" do
      expect(subject).to include "The provider state name is 'custom authorization is required'"
    end

    it "the output contains a success message" do
      expect(subject).to include "0 failures"
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
