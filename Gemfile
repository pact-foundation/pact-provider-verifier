source 'https://rubygems.org'

ruby ">= 2.6"

gemspec

if ENV['X_PACT_DEVELOPMENT']
  gem "pact", path: '../pact'
  gem "pact-message", path: '../pact-message-ruby'
  gem "pact-support", path: '../pact-support'
end

gem 'rack-reverse-proxy', git: 'https://github.com/pact-foundation/rack-reverse-proxy.git',
                          branch: 'feat/rack_2_and_3_compat'
