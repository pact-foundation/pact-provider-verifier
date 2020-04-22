#!/bin/sh

git pull origin master
set -e
bundle exec bump ${1:-minor} --no-commit
bundle exec rake generate_changelog
git add CHANGELOG.md lib/pact/provider_verifier/version.rb tasks/package.rake
git commit -m "chore: release $(bundle exec ruby -e "require 'rake'; load 'tasks/package.rake'; puts VERSION")" && git push
bundle exec rake tag_for_release
echo "Releasing from https://travis-ci.org/pact-foundation/pact-provider-verifier"