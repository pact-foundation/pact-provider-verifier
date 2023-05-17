ENV['PACT_BROKER_USERNAME'] = nil
ENV['PACT_BROKER_PASSWORD'] = nil
ENV['PACT_BROKER_TOKEN'] = nil
is_windows = Gem.win_platform?

RSpec.configure do | config |


  if config.respond_to?(:example_status_persistence_file_path=)
    config.example_status_persistence_file_path = "./spec/examples.txt"
  end
  config.filter_run_excluding skip_windows: is_windows
end