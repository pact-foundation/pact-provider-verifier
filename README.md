# Pact Provider Verification

This setup simplifies Pact Provider [verification](https://docs.pact.io/documentation/verifying_pacts.html)
process in any language, wrapping the Ruby implementation into a cross-platform,
binary-like CLI tool.

[![Test](https://github.com/pact-foundation/pact-provider-verifier/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/pact-foundation/pact-provider-verifier/actions/workflows/test.yml)

**Features**:

* Verify Pacts against Pacts published to an http endpoint, such as a [Pact Broker](https://github.com/pact-foundation/pact_broker)
* Verify local `*.json` Pacts on the file system
* Works with Pact [provider states](https://docs.pact.io/getting_started/provider_states) should you need them
* Publishes the verification results back to the pact broker if the pact was retrieved from a broker.
* ⚠️ - For Pact Specification V3/V4 support, see the new standalone [pact-verifier](https://github.com/pact-foundation/pact-reference/tree/master/rust/pact_verifier_cli#standalone-pact-verifier)

## Installation

### Docker

Take a look at https://hub.docker.com/r/pactfoundation/pact-cli

### Native Installation

Download the appropriate [release](https://github.com/pact-foundation/pact-ruby-standalone/releases)
for your OS and put somewhere on your `PATH`.

### With Ruby on Mac OSX and Linux

```
gem install pact-provider-verifier
pact-provider-verifier <args>
```

Run `pact-provider-verifier help` for command line options.

## Usage

```
Usage:
  pact-provider-verifier PACT_URL ... -h, --provider-base-url=PROVIDER_BASE_URL

Options:
  -h, --provider-base-url=PROVIDER_BASE_URL
          # Provider host URL
  -c, [--provider-states-setup-url=PROVIDER_STATES_SETUP_URL]
          # Base URL to setup the provider states at
      [--pact-broker-base-url=PACT_BROKER_BASE_URL]
          # Base URL of the Pact Broker from which to retrieve the pacts. Can also be set
            using the environment variable PACT_BROKER_BASE_URL.
  -n, [--broker-username=BROKER_USERNAME]
          # Pact Broker basic auth username. Can also be set using the environment
            variable PACT_BROKER_USERNAME.
  -p, [--broker-password=BROKER_PASSWORD]
          # Pact Broker basic auth password. Can also be set using the environment
            variable PACT_BROKER_PASSWORD.
  -k, [--broker-token=BROKER_TOKEN]
          # Pact Broker bearer token. Can also be set using the environment variable
            PACT_BROKER_TOKEN.
      [--provider=PROVIDER]
      [--consumer-version-tag=TAG]
          # Retrieve the latest pacts with this consumer version tag. Used in conjunction
            with --provider. May be specified multiple times.
      [--provider-version-tag=TAG]
          # Tag to apply to the provider application version. May be specified multiple times.
      [--provider-version-branch=BRANCH]
          # The name of the branch the provider version belongs to.
  -g, [--tag-with-git-branch], [--no-tag-with-git-branch]
          # Tag provider version with the name of the current git branch. Default: false
  -a, [--provider-app-version=PROVIDER_APP_VERSION]
          # Provider application version, required when publishing verification results
  -r, [--publish-verification-results], [--no-publish-verification-results]
          # Publish verification results to the broker. This can also be enabled by
            setting the environment variable PACT_BROKER_PUBLISH_VERIFICATION_RESULTS=true
      [--enable-pending], [--no-enable-pending]
          # Allow pacts which are in pending state to be verified without causing the
            overall task to fail. For more information, see https://pact.io/pending
      [--custom-provider-header=CUSTOM_PROVIDER_HEADER]
          # Header to add to provider state set up and pact verification requests. eg
            'Authorization: Basic cGFjdDpwYWN0'. May be specified multiple times.
      [--custom-middleware=FILE]
          # Ruby file containing a class implementing
            Pact::ProviderVerifier::CustomMiddleware. This allows the response to be modified before
            replaying. Use with caution!
  -v, [--verbose=VERBOSE]
          # Verbose output. Can also be set by setting the environment variable VERBOSE=true.
  -f, [--format=FORMATTER]
          # RSpec formatter. Defaults to custom Pact formatter. Other options are json
            and RspecJunitFormatter (which outputs xml).
  -o, [--out=FILE]
          # Write output to a file instead of $stdout.
      [--wait=SECONDS]
          # The number of seconds to poll for the provider to become available before
            running the verification

          # Default: 0
      [--log-dir=LOG_DIR]
          # The directory for the pact.log file
      [--log-level=LOG_LEVEL]
          # The log level

          # Default: debug
      [--fail-if-no-pacts-found]
          # If specified, will fail when no pacts are found

Description:
  The parameters used when fetching pacts dynamically from a Pact Broker are:

  --pact-broker-base-url (REQUIRED)
  --provider (REQUIRED)
  --broker-username/--broker-password or --broker-token
  --consumer-version-tag or --consumer-version-selector
  --enable-pending
  --include-wip-pacts-since

  To verify a pact at a known URL (eg. when a verification is triggered by a 'contract content changed'
  webhook), pass in the pact URL(s) as the first argument(s) to the command, and do NOT set any of the 
  other parameters apart from the base URL and credentials.

  To publish verification results for either of the above scenarios, set:

  --publish-verification-results (REQUIRED)
  --provider-app-version (REQUIRED)
  --provider-version-tag or --tag-with-git-branch


  Selectors: These are specified using JSON strings. The keys are 'tag' (the name of the consumer
  version tag), 'latest' (true|false), 'consumer', and 'fallbackTag'. For example '{\"tag\":
\"master\", \"latest\": true}'. For
  a detailed explanation of selectors, see https://pact.io/selectors#consumer-version-selectors
```

## Examples

See the [example](examples) for a demonstration with a [Sinatra](http://www.sinatrarb.com/) API:

```
cd examples
bundle install
./test.sh
```

### Simple API

*Steps*:

1. Create an API and a corresponding Docker image for it
1. Publish Pacts to the Pact broker (or create local ones)
1. Run the CLI tool for your OS, passing the appropriate arguments:
   * a space delimited list of local Pact file URLs or Pact Broker URLs.
   * `--provider-base-url` - the base url of the provider (i.e. your API)

eg.

```
pact-provider-verifier foo-bar.json --provider-base-url http://localhost:9292
```

### Setting a custom Authentication header

If you need to set a valid Authentication header for your replayed requests and provider state setup calls, specify `--custom-provider-header "Authentication: Type VALUE"` in the command line options.

Modification of the request headers is sometimes necessary, but be aware that any modification of the request before it is replayed lessens your confidence that the consumer and provider will work correctly in real life, so do it with caution.

### API with Provider States

Read the [Provider States section on docs.pact.io](https://docs.pact.io/getting_started/provider_states) for an introduction to provider states.

To allow the correct data to be set up before each interaction is replayed, you will need to create a dev/test only HTTP endpoint that accepts a JSON document that looks like:

```json
{
  "consumer": "CONSUMER_NAME",
  "state": "PROVIDER_STATE"
}
```

The endpoint should set up the given provider state for the given consumer synchronously, and return an error if the provider state is not recognised. Namespacing your provider states within each consumer will avoid clashes if more than one consumer defines the same provider state with different data.

The following flag is required when running the CLI:

* `--provider-states-setup-url` - the full url of the endpoint which sets the active consumer and provider state.

Rather than tearing down the specific test data created after each interaction, you should clear all the existing data at the start of each set up call. This is a more reliable method of ensuring that your test data does not leak from one test to another.

Note that the HTTP endpoint does not have to actually be within your application - it just has to have access to the same data store. So if you cannot add "test only" endpoints during your verification, consider making a separate app which shares credentials to your app's datastore. It is highly recommended that you run your verifications against a locally running provider, rather than a deployed one, as this will make it much easier to stub any downstream calls, debug issues, and it will make your tests run as fast as possible.

Ignore the `states` array that you will see if you happen to print out the live provider state set up request body - that was an attempt to make the set up call forwards compatible with the v3 pact specification, which allows multiple provider states. Unfortunately, this forwards compatibilty attempt failed, because the v3 provider states support a map of params, not just a name, so it should have been `{ "state": { "name": "PROVIDER_STATE, "params": {...} } }`. See the next section for the actual v3 support.

#### Pact specification v3 provider state support

The v3 Pact specification adds support for multiple provider states, and provider state params. If you are verifying a pact with multiple provider states, then set up URL will be invoked once for each state. The `params` hash from the pact will also be passed through in the JSON document with the key name `params`.

### Using the Pact Broker with Basic authentication

The following flags are required to use basic authentication with a Pact Broker:

* `--broker-user` - the Username for Pact Broker basic authentication.
* `--broker-password` - the Password for Pact Broker basic authentication.

NOTE: the `http://user:password@host` format for basic HTTP auth is not supported.

## Compatibility

<details><summary>Specification Compatibility</summary>

| Version  | Stable | [Spec] Compatibility | 
| -------  | ------ | -------------------- |
| 1.x.x    | Yes    | 2, 3\*               |

_\*_ v3 support is limited to the subset of functionality required to enable language inter-operable [Message support].

See V3 tracking [issue](https://github.com/pact-foundation/pact-ruby/issues/318) for more detail

Want V3/V4 support now? See the new standalone [pact-verifier](https://github.com/pact-foundation/pact-reference/tree/master/rust/pact_verifier_cli#standalone-pact-verifier)

[message support]: https://github.com/pact-foundation/pact-specification/tree/version-3#introduces-messages-for-services-that-communicate-via-event-streams-and-message-queues

## Contributing

See [CONTRIBUTING.md](/CONTRIBUTING.md)

[pact]: https://github.com/realestate-com-au/pact
[releases]: https://github.com/bethesque/pact-mock_service/releases
[javascript]: https://github.com/DiUS/pact-consumer-js-dsl
[pact-dev]: https://groups.google.com/forum/#!forum/pact-dev
[windows]: https://github.com/bethesque/pact-mock_service/wiki/Building-a-Windows-standalone-executable
[install-windows]: https://github.com/bethesque/pact-mock_service/wiki/Installing-the-pact-mock_service-gem-on-Windows
[why-generated]: https://github.com/realestate-com-au/pact/wiki/FAQ#why-are-the-pacts-generated-and-not-static
