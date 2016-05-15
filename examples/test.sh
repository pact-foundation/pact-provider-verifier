#!/usr/bin/env ruby

puts "=> Starting API"
pipe = IO.popen("ruby api.rb")
sleep 2

puts "=> Running Pact"
# puts "=> Test FAILING Pact"
# res = `ruby -I../lib ../bin/pact-provider-verifier --provider-base-url http://localhost:4567 --pact-urls ./fail.json --provider_states_setup_url http://localhost:4567/provider-state --provider_states_url http://localhost:4567/provider-states`

puts "=> Test SUCCESSFUL Pact"
res = `ruby -I../lib ../bin/pact-provider-verifier --provider-base-url http://localhost:4567 --pact-urls ./me-they.json,./another-they.json --provider_states_setup_url http://localhost:4567/provider-state --provider_states_url http://localhost:4567/provider-states`

# Test the actual gem
# res = `../pkg/pact-provider-verifier-0.0.2-1-osx/bin/pact-provider-verifier --provider-base-url http://localhost:4567 --pact-urls ./me-they.json,./another-they.json --provider_states_setup_url http://localhost:4567/provider-state --provider_states_url http://localhost:4567/provider-states`
code = $?

puts "=> Shutting down API"
Process.kill 'TERM', pipe.pid

puts "Test exit status: #{res}"
puts
puts
exit code.exitstatus
