describe "pact-provider-verifier with basic auth" do
  before(:all) do
    @pipe = IO.popen({'USE_BASIC_AUTH' => 'true'}, %w{bundle exec rackup -p 4570 spec/support/config.ru})
    sleep 2
  end

  context "with --custom-provider-header specified" do

    subject { `bundle exec bin/pact-provider-verifier spec/support/pacts/needs-custom-auth.json --custom-middleware #{Dir.pwd}/spec/support/custom_middleware.rb -a 1.0.100 --provider-base-url http://localhost:4570 2>&1` }

    it "exits with a 0 exit code" do
      subject
      puts subject
      expect($?).to eq 0
    end

    it "the output contains a success message" do
      expect(subject).to include "0 failures"
    end
  end

  after(:all) do
    Process.kill 'KILL', @pipe.pid
  end
end
