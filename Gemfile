source 'https://rubygems.org'

ruby ">= 2.6"

gemspec

if ENV['X_PACT_DEVELOPMENT']
  gem "pact", path: '../pact'
  gem "pact-message", path: '../pact-message-ruby'
  gem "pact-support", path: '../pact-support'
else
  gem "pact-support", git: 'https://github.com/pact-foundation/pact-support.git', branch: 'feat/v3_generators'
  gem "pact", git: 'https://github.com/pact-foundation/pact-ruby.git', branch: 'feat/v3_generators'
end
