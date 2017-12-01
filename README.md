# Pact Provider Verification

This setup simplifies Pact Provider [verification](https://docs.pact.io/documentation/verifying_pacts.html)
process in any language, wrapping the Ruby implementation into a cross-platform,
binary-like CLI tool.

[![Build Status](https://travis-ci.org/pact-foundation/pact-provider-verifier.svg?branch=master)](https://travis-ci.org/pact-foundation/pact-provider-verifier)

**Features**:

* Verify Pacts against Pacts published to an http endpoint, such as a [Pact Broker](https://github.com/pact-foundation/pact_broker)
* Verify local `*.json` Pacts on the file system
* Works with Pact [provider states](https://docs.pact.io/documentation/provider_states.html) should you need them
* Publishes the verification results back to the pact broker if the pact was retrieved from a broker.

## Installation

### Docker

Take a look at https://github.com/DiUS/pact-provider-verifier-docker.

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
  -h, --provider-base-url=PROVIDER_BASE_URL                          # Provider host URL
  -c, [--provider-states-setup-url=PROVIDER_STATES_SETUP_URL]        # Base URL to setup the provider states at
  -a, [--provider-app-version=PROVIDER_APP_VERSION]                  # Provider application version, required when publishing verification results
  -r, [--publish-verification-results=PUBLISH_VERIFICATION_RESULTS]  # Publish verification results to the broker
  -n, [--broker-username=BROKER_USERNAME]                            # Pact Broker basic auth username
  -p, [--broker-password=BROKER_PASSWORD]                            # Pact Broker basic auth password
      [--custom-provider-header=CUSTOM_PROVIDER_HEADER]              # Header to add to provider state set up and pact verification requests. eg 'Authorization: Basic cGFjdDpwYWN0'. May be specified multiple times.
  -v, [--verbose=VERBOSE]                                            # Verbose output
  -f, [--format=FORMATTER]                                           # RSpec formatter. Defaults to custom Pact formatter. json and RspecJunitFormatter may also be used.
  -u, [--pact-urls=PACT_URLS]                                        # DEPRECATED. Please provide as space separated arguments.

Verify pact(s) against a provider. Supports local and networked (http-based) files.
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

Read the [Provider States section on docs.pact.io](https://docs.pact.io/documentation/provider_states.html) for an introduction to provider states.

To allow the correct data to be set up before each interaction is replayed, you will need to create an HTTP endpoint (which may or may not actually be in the same application as your provider) that accepts a JSON document that looks like:

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

### Using the Pact Broker with Basic authentication

The following flags are required to use basic authentication with a Pact Broker:

* `--broker-user` - the Username for Pact Broker basic authentication.
* `--broker-password` - the Password for Pact Broker basic authentication.

NOTE: the `http://user:password@host` format for basic HTTP auth is not supported.

## Contributing

See [CONTRIBUTING.md](/CONTRIBUTING.md)

[pact]: https://github.com/realestate-com-au/pact
[releases]: https://github.com/bethesque/pact-mock_service/releases
[javascript]: https://github.com/DiUS/pact-consumer-js-dsl
[pact-dev]: https://groups.google.com/forum/#!forum/pact-dev
[windows]: https://github.com/bethesque/pact-mock_service/wiki/Building-a-Windows-standalone-executable
[install-windows]: https://github.com/bethesque/pact-mock_service/wiki/Installing-the-pact-mock_service-gem-on-Windows
[why-generated]: https://github.com/realestate-com-au/pact/wiki/FAQ#why-are-the-pacts-generated-and-not-static
