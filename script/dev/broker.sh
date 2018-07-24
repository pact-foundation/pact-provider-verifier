bundle exec rackup -p 4567 spec/support/config.ru 2> /dev/null &
pid=$!
sleep 3

bundle exec bin/pact-provider-verifier --provider Bar --consumer-version-tag prod --pact-broker-base-url http://localhost:9292 -a 1.0.100 --provider-base-url http://localhost:4567 --provider-states-setup-url http://localhost:4567/provider-state

kill -2 $pid
wait $pid