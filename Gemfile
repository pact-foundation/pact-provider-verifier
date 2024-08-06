source 'https://rubygems.org'

ruby ">= 2.6"

gemspec

if ENV['X_PACT_DEVELOPMENT']
  gem "pact", path: '../pact'
  gem "pact-message", path: '../pact-message-ruby'
  gem "pact-support", path: '../pact-support'
end

if ENV['RACK_VERSION'] == '2'
  gem 'rack-reverse-proxy'
else
  gem 'rack-reverse-proxy', git: 'https://github.com/samedi/rack-reverse-proxy.git', ref: '06f21feb6afbbf902969c4f1df219df8f2080387'
end
