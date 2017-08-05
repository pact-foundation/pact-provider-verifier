# Releasing

1. Set the version numbers.

    1. Increment the version according to semantic versioning rules in `lib/pact/provider_verifier/version.rb`.
    1. Set the package number (eg. "-1") in `tasks/package.rake`. This is required because the same gem version may be packaged multiple times.

2. Update the `CHANGELOG.md` using:

    # Not tested yet!
    $ bundle exec generate_changelog

3. Add files to git

    $ git add CHANGELOG.md lib/pact/provider_verifier/version.rb tasks/package.rake

4. Commit

    $ git commit -m "chore: release $(bundle exec ruby -e "require 'rake'; load 'tasks/package.rake'; puts VERSION")" && git push

5. Tag

    $ bundle exec rake tag_for_release
