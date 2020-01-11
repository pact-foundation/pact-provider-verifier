<a name="v1.26.0-1"></a>
### v1.26.0-1 (2020-01-11)


#### Features

* **cli**
  * allow publishing of verification results to be enabled by setting the environment variable PACT_BROKER_PUBLISH_VERIFICATION_RESULTS=true	 ([14e37f0](/../../commit/14e37f0))
  * add --enable-pending parameter to CLI	 ([0b32a1c](/../../commit/0b32a1c))
  * add --consumer-version-selector parameter	 ([2526590](/../../commit/2526590))
  * add long description	 ([905ab8d](/../../commit/905ab8d))


<a name="v1.25.1-1"></a>
### v1.25.1-1 (2019-11-10)


#### Bug Fixes

* **basic auth**
  * add missing basic auth credentials for retriving pacts by URL	 ([e84f9b8](/../../commit/e84f9b8))


<a name="v1.25.0-1"></a>
### v1.25.0-1 (2019-11-09)

#### Features

* **gems**
  * update pact gem to 1.42.2	 ([a8452bd](/../../commit/a8452bd))
  * update pact gem to 1.42.1	 ([44cdd4e](/../../commit/44cdd4e))


<a name="v1.24.0-1"></a>
### v1.24.0-1 (2019-09-26)


#### Features

* update pact version dependency to 1.42.0	 ([828deff](/../../commit/828deff))
* use new 'pacts for verification' endpoint when PACT_BROKER_PACTS_FOR_VERIFICATION_ENABLED is set to 'true'	 ([6e6f45b](/../../commit/6e6f45b))
* allow --provider-version-tag to be specified, which will be applied to the provider version when the verification results are published	 ([bf4bc93](/../../commit/bf4bc93))


<a name="v1.23.1-1"></a>
### v1.23.1-1 (2019-05-22)


#### Bug Fixes

* honour the --broker-token CLI param	 ([36bc88c](/../../commit/36bc88c))


<a name="v1.23.0-1"></a>
### v1.23.0-1 (2019-04-28)


#### Features

* allow a wait time to be specified to allow the provider to become available	 ([cec8d56](/../../commit/cec8d56))


<a name="v1.22.0-1"></a>
### v1.22.0-1 (2019-02-21)


#### Features

* add support for bearer token	 ([3a102c4](/../../commit/3a102c4))
* add support for bearer token	 ([bc37817](/../../commit/bc37817))


<a name="v1.21.0-1"></a>
### v1.21.0-1 (2018-11-15)


#### Features

* pass verbose flag through to HAL client when fetching pacts	 ([d3acd1a](/../../commit/d3acd1a))


<a name="v1.20.0-1"></a>
### v1.20.0-1 (2018-10-04)


#### Features

* **pact specification v3**
  * add support for multiple provider states and params	 ([556b957](/../../commit/556b957))


<a name="v1.18.0-1"></a>
### v1.18.0-1 (2018-09-11)


#### Features

* **pending pacts**
  * allow pending pacts to be feature toggled	 ([5e8e15f](/../../commit/5e8e15f))

* allow custom rack middleware to be specified	 ([ef857d4](/../../commit/ef857d4))

* **custom-middleware**
  * allow custom middleware to be configured via the command line	 ([217136d](/../../commit/217136d))


<a name="v1.17.0-1"></a>
### v1.17.0-1 (2018-09-06)


#### Features

* rename wip in CLI to ignore-failures and wip pacts to pending pacts	 ([bf9ed81](/../../commit/bf9ed81))


<a name="v1.16.1-1"></a>
### v1.16.1-1 (2018-09-05)


#### Features

* **cli**
  * update help text	 ([740dc4b](/../../commit/740dc4b))


<a name="v1.16.0-1"></a>
### v1.16.0-1 (2018-07-24)


#### Features

* allow pacts to be fetched from a Pact Broker by provider name, including WIP pacts.	 ([0b80528](/../../commit/0b80528))
* correct debug message regarding provider state URL	 ([d134ba6](/../../commit/d134ba6))


<a name="v1.15.0-1"></a>
### v1.15.0-1 (2018-07-13)


#### Features

* print a new line between JSON documents when using --format json	 ([dc90d8e](/../../commit/dc90d8e))


<a name="v1.14.4-1"></a>
### v1.14.4-1 (2018-07-10)


#### Bug Fixes

* ensure all json results are sent to stdout when multiple pacts are verified	 ([7662df0](/../../commit/7662df0))


<a name="v1.14.1-1"></a>
### v1.14.1-1 (2018-05-08)


#### Bug Fixes

* ensure headers with underscores are correctly replayed	 ([abb4b4a](/../../commit/abb4b4a))


<a name="v1.14.0-1"></a>
### v1.14.0-1 (2018-04-16)


#### Features

* add --out option to CLI to allow test results to be written to a file	 ([8be3367](/../../commit/8be3367))


<a name="v1.13.0-1"></a>
### v1.13.0-1 (2018-04-05)


#### Bug Fixes

* ensure v3 message matching rules are loaded correctly	 ([48f29a1](/../../commit/48f29a1))


<a name="v1.12.0-1"></a>
### v1.12.0-1 (2018-03-24)


#### Features

* add message pact verification support - alpha release only	 ([69cd7e9](/../../commit/69cd7e9))


<a name="v1.11.0-1"></a>
### v1.11.0-1 (2017-12-07)


#### Features

* maintain path portion of specified provider base URL	 ([b765b00](/../../commit/b765b00))


<a name="v1.10.0-1"></a>
### v1.10.0-1 (2017-11-11)


#### Features

* add support for --format RspecJunitFormatter	 ([2ba6439](/../../commit/2ba6439))


<a name="v1.9.0-1"></a>
### v1.9.0-1 (2017-11-07)


#### Features

* **monkeypatch**
  * allow a ruby file to be loaded in order to perform at monkeypatch	 ([96bb549](/../../commit/96bb549))


<a name="v1.8.0-1"></a>
### v1.8.0-1 (2017-10-27)

#### Features

* **cli**
  * allow --format json to be used to output spec results in json format to stdout	 ([aa7359a](/../../commit/aa7359a))

<a name="v1.7.0-1"></a>
### v1.7.0-1 (2017-10-18)

#### Features

* allow backtrace toggle to be configured via an environment variable	 ([298d791](/../../commit/298d791))

<a name="v1.6.0-1"></a>
### v1.6.0-1 (2017-10-01)

#### Features

* **cli**
  * allow multiple --custom-provider-header to be specified	 ([6a8573a](/../../commit/6a8573a))

<a name="v1.5.0-1"></a>
### v1.5.0-1 (2017-10-01)

#### Features

* **cli**
  * specify pact urls as the arguments to pact-provider-verifier instead of using --pact-urls option	 ([df78617](/../../commit/df78617))

<a name="v1.4.1-1"></a>
### v1.4.1-1 (2017-08-27)

#### Bug Fixes

* ensure Host header is correctly set	 ([9048744](/../../commit/9048744))

<a name="v1.4.0-1"></a>
### v1.4.0-1 (2017-08-11)

#### Features

* **run single interaction**
  * allow env vars to be set to run a single interaction   ([3e39517](/../../commit/3e39517))

#### Bug Fixes

* Turn off SSL verification for provider states setup call.  ([744add2](/../../commit/744add2))

<a name="v1.3.1"></a>
### v1.3.1 (2017-08-08)

#### Bug Fixes

* **windows**
  * Add retries for flakiness demonstrated on windows builds for pact-go	 ([198efef](/../../commit/198efef))

<a name="v1.3.0-1"></a>
# v1.3.0 (2017-08-08)

#### Features

* **custom provider header**
  * Allow a --custom-provider-header to be specified   ([e3ea6fa](/../../commit/e3ea6fa))

<a name="1.2.0"></a>
# 1.2.0 (2017-08-05)

* chore(gems): Change json version to allow >1.8 ([b91391a](https://github.com/pact-foundation/pact-provider-verifier/commit/b91391a))

# 1.1.3 (02 June 2017)
* 066fa60 - Add states list to state setup JSON body, to prepare for v3 pact spec which allows multiple provider states (Beth Skurrie, Fri Jun 2 15:01:28 2017 +1000)

# 1.1.2 (02 June 2017)
* da958c0 - Only set up state if a provider-states-setup-url is provided. Add tests for SetUpProviderState. (Beth Skurrie, Fri Jun 2 14:31:27 2017 +1000)
* 36ef2eb - Remove .java, .class, .gitignore and .travis.yml files from package (Beth Skurrie, Fri Jun 2 10:32:55 2017 +1000)
* 7902674 - Add rake tasks to generate and upload release notes. (Beth Skurrie, Fri Jun 2 10:12:17 2017 +1000)
* 01e811e - Add integration specs for command (Beth Skurrie, Fri Jun 2 05:51:30 2017 +1000)

# 1.1.0 (01 June 2017)
* 7106832 - chore(docs): update docs for provider states URL (Matt Fellows, Fri May 26 22:45:09 2017 +1000)
* 8f787e6 - Add deprecation warning for --provider-states-url (Beth Skurrie, Fri May 26 20:51:48 2017 +1000)
* 982ba7c - Remove need for provider-states-url by dynamically calling the set up code during test execution (Beth Skurrie, Fri May 26 16:30:14 2017 +1000)
* f055375 - Turn silent mode on for zip task in rake package (Beth Skurrie, Tue May 23 09:34:51 2017 +1000)

# 1.0.2 (23 May 2017)
* 33f0811 - Upgrade rspec version to ~>3.5 to fix #11 (Beth Skurrie, Tue May 23 09:01:07 2017 +1000)

# 1.0.1 (9 May 2017)
* 94597a0 - Updated pact gem to allow use of https for publishing verifications (Beth Skurrie, Tue May 9 14:27:19 2017 +1000)

# 1.0.0 (9 May 2017)

# 0.0.4 (15 May 2016)

* c5dc292 - Added basic authentication support for Pact Broker URLs (Matt Fellows, Sun May 15 19:08:22 2016 +1000)

# 0.0.3 (15 May 2016)

* d36ae19 - Release v0.0.3 (Matt Fellows, Sun May 15 11:22:41 2016 +1000)

# 0.0.2 (12 May 2016)

* 0aca507 - Refactored to not use the Pact rake tasks. Traveling Ruby does not like shelling out to a Ruby process (where's my Gems?) (Matt Fellows, Thu May 12 21:55:29 2016 +1000)
* 9feb60e - Verifier properly runs all Pacts provided and handles Pact CLI exit call (Matt Fellows, Sun May 15 11:22:12 2016 +1000)
* a85903d - Release template (Matt Fellows, Thu May 12 21:53:22 2016 +1000)
* 059b488 - Setting execute perms on wrapper script during package (Matt Fellows, Thu May 12 22:30:22 2016 +1000)

# 0.0.1 (8 May 2016)

* 39e75f3 - Pact provider verifier cross-platform CLI tool (Matt Fellows, Thu May 12 07:30:47 2016 +1000)
