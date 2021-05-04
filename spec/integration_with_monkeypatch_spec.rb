describe "pact-provider-verifier with monkeypatch" do
  before(:all) do
    @pipe = IO.popen({}, %w{bundle exec rackup -p 4870 spec/support/config.ru})
    sleep 2
  end

  let(:env) { 'VERBOSE_LOGGING=true' }
  subject { `#{env} bundle exec bin/pact-provider-verifier ./test/me-they.json #{monkey_patch_args} -a 1.0.100 --provider-base-url http://localhost:4870 --provider_states_setup_url http://localhost:4870/provider-state 2>&1` }

  describe 'loading two different monkey patches' do
    let(:monkey_patch_args) { "--monkeypatch #{Dir.pwd}/spec/support/monkeypatch.rb --monkeypatch #{Dir.pwd}/spec/support/another_monkeypatch.rb" }

    it "exits with a 0 exit code" do
      subject
      puts subject
      expect($?).to eq 0
    end

    it "loads the monkeypatch file" do
      expect(subject).to include("THIS IS A MONKEYPATCHING FILE!!!")
      expect(subject).to include("THIS IS ANOTHER MONKEYPATCHING FILE!!!")
    end
  end

  describe 'loading same monkey' do
    let(:monkey_patch_args) { "--monkeypatch #{Dir.pwd}/spec/support/monkeypatch.rb --monkeypatch #{Dir.pwd}/spec/support/monkeypatch.rb" }

    it "exits with a 0 exit code" do
      subject
      puts subject
      expect($?).to eq 0
    end

    it "loads the monkeypatch file twice" do
      expect(subject).to include("THIS IS A MONKEYPATCHING FILE!!!").twice
      expect(subject).to include("DEBUG: Loading monkeypatch file").twice
    end
  end

  after(:all) do
    Process.kill 'KILL', @pipe.pid
  end
end
