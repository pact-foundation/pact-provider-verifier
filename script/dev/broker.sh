bundle exec rackup -p 4567 script/dev/bar_provider_config.ru 2> /dev/null &
pid=$!
sleep 3

  # --consumer-version-selector '{"tag": "dev", "latest": true}' \
  # --provider-states-setup-url http://localhost:4567/provider-state \
  # --provider-version-tag "pdev" "foo" \
  # --format json \
  # --consumer-version-selector '{"tag": "dev", "latest": true}' \
  # --tag-with-git-branch \
  # --verbose
export PACT_BROKER_PUBLISH_VERIFICATION_RESULTS=true
export PACT_BROKER_BASE_URL=https://test.pact.dius.com.au
export PACT_BROKER_USERNAME=dXfltyFMgNOFZAxr8io9wJ37iUpY42M
export PACT_BROKER_PASSWORD=O5AIZWxelWbLvqMd8PkAVycBJh2Psyg1
bundle exec bin/pact-provider-verifier  \
  --provider "Bar" \
  --consumer-version-tag dev \
  --consumer-version-tag dev2 \
  --provider-app-version $(git rev-parse --short HEAD | xargs echo -n) \
  --provider-base-url http://localhost:4567 \
  --enable-pending

kill -2 $pid
wait $pid
