# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pact/provider_verifier/version'

Gem::Specification.new do |gem|
  gem.name          = "pact-provider-verifier"
  gem.version       = Pact::ProviderVerifier::VERSION
  gem.authors       = ["Matt Fellows"]
  gem.email         = ["m@onegeek.com.au"]
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
  gem.add_runtime_dependency 'pact', '~>1.13'
  gem.add_runtime_dependency 'pact-provider-proxy', '~>2.1'
  gem.add_runtime_dependency 'faraday', '~> 0.9', '>= 0.9.0'
  gem.add_runtime_dependency 'faraday_middleware', '~> 0.10'
  gem.add_runtime_dependency 'json',  '~>1.8'
  gem.add_runtime_dependency 'rack', '~> 2.0'
  gem.add_runtime_dependency 'rake', '~> 10.4', '>= 10.4.2'

  gem.add_development_dependency 'sinatra'
  gem.add_development_dependency 'sinatra-contrib'
  gem.add_development_dependency 'octokit', '~> 4.7'
  gem.add_development_dependency 'webmock', '~>3.0'

end
