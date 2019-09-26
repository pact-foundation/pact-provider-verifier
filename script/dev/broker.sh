bundle exec rackup -p 4567 script/dev/bar_provider_config.ru 2> /dev/null &
pid=$!
sleep 3

export PACT_BROKER_PACTS_FOR_VERIFICATION_ENABLED=true
# bundle exec bin/pact-provider-verifier --provider Bar --consumer-version-tag prod --pact-broker-base-url http://localhost:9292 -a 1.0.100 --provider-base-url http://localhost:4567 --provider-states-setup-url http://localhost:4567/provider-state
  # --consumer-version-tag dev \
bundle exec bin/pact-provider-verifier --broker-token localhost \
  --provider Bar \
  --provider-version-tag pdev \
  --pact-broker-base-url http://localhost:9292 \
  -a 1.0.100 --provider-base-url http://localhost:4567 \
  --provider-states-setup-url http://localhost:4567/provider-state \
  --publish-verification-results

kill -2 $pid
wait $pid