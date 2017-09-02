#!/bin/bash
# For some reason, the process in spec/integration_with_ssl_no_verify_spec.rb
# doesn't shut down properly on travis, and often reports the error
# 'TCPServer Error: Address already in use - bind(2) for "::" port XXXX'
# when starting up, despite the fact that the port is dynamically assigned.
# The hanging process causes the build to fail, even if everything else has passed.

ps -ef | grep rspec | grep -v grep
ruby_processes=$(ps -ef | grep rspec | grep -v grep | awk '{ print $2 }')
for pid in ${ruby_processes}; do
  kill -9 ${pid}
done
