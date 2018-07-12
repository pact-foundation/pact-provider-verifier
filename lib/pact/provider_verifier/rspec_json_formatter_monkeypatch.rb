require 'rspec'

begin
  require 'rspec/core/formatters/json_formatter'

  RSpec::Core::Formatters::JsonFormatter

  # This looks dodgy, but it's actually safer than inheriting from
  # RSpec::Core::Formatters::JsonFormatter and using a custom class,
  # because if the JsonFormatter class gets refactored,
  # the --format json option will still work, but the inheritance will break.

  module RSpec
    module Core
      module Formatters
        class JsonFormatter
          alias_method :old_close, :close

          def close(*args)
            # Append a new line so that the output stream can be split at
            # the new lines, and each JSON document parsed separately
            old_close(*args)
            output.write("\n")
          end
        end
      end
    end
  end

rescue NameError
  Pact.configuration.error_stream.puts "WARN: Could not find RSpec::Core::Formatters::JsonFormatter to modify it to put a new line between JSON result documents."
rescue LoadError
  Pact.configuration.error_stream.puts "WARN: Could not load rspec/core/formatters/json_formatter to modify it to put a new line between JSON result documents."
end
