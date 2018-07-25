RSpec.configure do | config |

  if config.respond_to?(:example_status_persistence_file_path=)
    config.example_status_persistence_file_path = "./spec/examples.txt"
  end

end