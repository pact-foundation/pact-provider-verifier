# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pact/provider_verifier/version'

Gem::Specification.new do |gem|
  gem.name          = "pact-provider-verifier"
  gem.version       = Pact::ProviderVerifier::VERSION
  gem.authors       = ["Matt Fellows", "Beth Skurrie"]
  gem.email         = ["m@onegeek.com.au", "beth@bethesque.com"]
  gem.summary       = %q{Provides a Pact verification service for use with Pact}
  gem.homepage      = "https://github.com/pact-foundation/pact-provider-verifier"
  gem.description   = %q{A cross-platform Pact verification tool to validate API Providers.
                      Used in the pact-js-provider project to simplify development}

  gem.files         = Dir.glob("{bin,lib}/**/*") + Dir.glob(%w(Gemfile LICENSE.txt README.md CHANGELOG.md))

  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.license       = 'MIT'

  gem.add_runtime_dependency 'rspec', '~> 3.5'
  gem.add_runtime_dependency 'pact', '~> 1.59'
  gem.add_runtime_dependency 'pact-message', '~>0.5'
  gem.add_runtime_dependency 'faraday', '~> 2.5'
  gem.add_runtime_dependency 'faraday-retry', '~> 2.2'
  gem.add_runtime_dependency 'json',  '>1.8'
  gem.add_runtime_dependency 'rack', '~> 2.1'
  gem.add_runtime_dependency 'rack-reverse-proxy'
  gem.add_runtime_dependency 'rspec_junit_formatter', '~> 0.3'

  gem.add_development_dependency 'rake', '~> 13.0'
  gem.add_development_dependency 'sinatra'
  gem.add_development_dependency 'sinatra-contrib'
  gem.add_development_dependency 'octokit', '~> 4.7'
  gem.add_development_dependency 'webmock', '~>3.0'
  gem.add_development_dependency 'conventional-changelog', '~>1.2'
  gem.add_development_dependency 'pry-byebug', '~>3.4'
  gem.add_development_dependency 'find_a_port', '~>1.0'
  gem.add_development_dependency 'bump', '~> 0.5'
  gem.add_development_dependency 'word_wrap'
end
