# For Bundler.with_clean_env
require 'bundler/setup'
require 'pact/provider_verifier/version'

PACKAGE_NAME = "pact-provider-verifier"
VERSION = "#{Pact::ProviderVerifier::VERSION}-1"
TRAVELING_RUBY_VERSION = "20150210-2.1.5"

desc "Package pact-provider-verifier for OSX, Linux x86 and Linux x86_64"
task :package => ['package:linux:x86', 'package:linux:x86_64', 'package:osx', 'package:win32']

namespace :package do
  namespace :linux do
    desc "Package pact-provider-verifier for Linux x86"
    task :x86 => [:bundle_install, "build/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86.tar.gz"] do
      create_package(TRAVELING_RUBY_VERSION, "linux-x86")
    end

    desc "Package pact-provider-verifier for Linux x86_64"
    task :x86_64 => [:bundle_install, "build/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz"] do
      create_package(TRAVELING_RUBY_VERSION, "linux-x86_64")
    end
  end

  desc "Package pact-provider-verifier for OS X"
  task :osx => [:bundle_install, "build/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz"] do
    create_package(TRAVELING_RUBY_VERSION, "osx")
  end

  desc "Package pact-provider-verifier for Windows x86"
  task :win32 => [:bundle_install, "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-win32.tar.gz"] do
    create_package(TRAVELING_RUBY_VERSION, "win32", :windows)
  end

  desc "Install gems to local directory"
  task :bundle_install do
    if RUBY_VERSION !~ /^2\.1\./
      abort "You can only 'bundle install' using Ruby 2.1, because that's what Traveling Ruby uses."
    end
    sh "rm -rf build/tmp"
    sh "mkdir -p build/tmp"
    sh "cp pact-provider-verifier.gemspec  Gemfile Gemfile.lock build/tmp/"
    sh "mkdir -p build/tmp/lib/pact/provider_verifier"
    sh "cp lib/pact/provider_verifier/version.rb build/tmp/lib/pact/provider_verifier/version.rb"
    Bundler.with_clean_env do
      sh "cd build/tmp && env BUNDLE_IGNORE_CONFIG=1 bundle install --path ../vendor --without development"
    end
    sh "rm -rf build/tmp"
    sh "rm -f build/vendor/*/*/cache/*"
  end
end

file "build/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86.tar.gz" do
  download_runtime(TRAVELING_RUBY_VERSION, "linux-x86")
end

file "build/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz" do
  download_runtime(TRAVELING_RUBY_VERSION, "linux-x86_64")
end

file "build/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz" do
  download_runtime(TRAVELING_RUBY_VERSION, "osx")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-win32.tar.gz" do
  download_runtime(TRAVELING_RUBY_VERSION, "win32")
end

def create_package(version, target, os_type = :unix)
  package_dir = "#{PACKAGE_NAME}-#{VERSION}-#{target}"
  sh "rm -rf #{package_dir}"
  sh "mkdir #{package_dir}"
  sh "mkdir -p #{package_dir}/lib/app"
  sh "mkdir -p #{package_dir}/bin"
  sh "cp packaging/pact-provider-verifier.rb #{package_dir}/lib/app/pact-provider-verifier.rb"
  sh "cp -pR lib #{package_dir}/lib/app"
  sh "mkdir #{package_dir}/lib/ruby"
  sh "tar -xzf build/traveling-ruby-#{version}-#{target}.tar.gz -C #{package_dir}/lib/ruby"

  if os_type == :unix
    sh "cp packaging/wrapper.sh #{package_dir}/bin/pact-provider-verifier"
  else
    sh "cp packaging/wrapper.bat #{package_dir}/bin/pact-provider-verifier.bat"
  end

  sh "cp -pR build/vendor #{package_dir}/lib/"
  sh "cp pact-provider-verifier.gemspec Gemfile Gemfile.lock #{package_dir}/lib/vendor/"
  sh "mkdir #{package_dir}/lib/vendor/.bundle"
  sh "cp packaging/bundler-config #{package_dir}/lib/vendor/.bundle/config"
  if !ENV['DIR_ONLY']
    sh "mkdir -p pkg"

    if os_type == :unix
      sh "tar -czf pkg/#{package_dir}.tar.gz #{package_dir}"
    else
      sh "zip -9r pkg/#{package_dir}.zip #{package_dir}"
    end

    sh "rm -rf #{package_dir}"
  end
end

def download_runtime(version, target)
  sh "cd build && curl -L -O --fail " +
    "http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-#{version}-#{target}.tar.gz"
end
