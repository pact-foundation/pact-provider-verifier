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
# export PACT_BROKER_PUBLISH_VERIFICATION_RESULTS=false
# export PACT_BROKER_BASE_URL=https://bethtest.test.pactflow.io
# export PACT_BROKER_TOKEN=J4lCBjh5Z9vVEofBdrZnXw
export PACT_BROKER_PUBLISH_VERIFICATION_RESULTS=false
export PACT_BROKER_BASE_URL=http://localhost:9292
# export PACT_BROKER_TOKEN=J4lCBjh5Z9vVEofBdrZnXw
  # --provider "Bar" \
  # --provider-version-tag dev \
  # --consumer-version-tag dev \
  # --consumer-version-tag dev2 \
bundle exec bin/pact-provider-verifier  \
  --provider "Example API" \
  --provider-app-version $(git rev-parse --short HEAD | xargs echo -n) \
  --provider-version-branch "main" \
  --provider-version-tag "foo" \
  --provider-base-url http://localhost:4567 \
  --include-wip-pacts-since 2018-01-01 \
  --enable-pending  \
  --no-fail-if-no-pacts-found \
  --verbose

echo "exit code is $?"

kill -2 $pid
wait $pid
