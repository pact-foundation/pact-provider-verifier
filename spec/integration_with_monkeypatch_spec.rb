describe "pact-provider-verifier with monkeypatch" do
  before(:all) do
    @pipe = IO.popen({}, %w{bundle exec rackup -p 4870 spec/support/config.ru})
    sleep 2
  end

  subject { `bundle exec bin/pact-provider-verifier ./test/me-they.json --monkeypatch #{Dir.pwd}/spec/support/monkeypatch.rb --monkeypatch #{Dir.pwd}/spec/support/another_monkeypatch.rb -a 1.0.100 --provider-base-url http://localhost:4870 --provider_states_setup_url http://localhost:4870/provider-state 2>&1` }

  it "exits with a 0 exit code" do
    subject
    puts subject
    expect($?).to eq 0
  end

  it "loads the monkeypatch file" do
    expect(subject).to include "THIS IS A MONKEYPATCHING FILE!!!"
    expect(subject).to include "THIS IS ANOTHER MONKEYPATCHING FILE!!!"
  end


  after(:all) do
    if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
      system("taskkill /im #{@pipe.pid}  /f /t >nul 2>&1")
    else
      Process.kill 'KILL', @pipe.pid
    end
  end
end
