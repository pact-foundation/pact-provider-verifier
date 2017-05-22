# Releasing

1. Increment the version according to semantic versioning rules in `lib/pact/provider_verifier/version.rb`

2. Update the `CHANGELOG.md` using:

    $ git log --pretty=format:'  * %h - %s (%an, %ad)' vX.Y.Z..HEAD

3. Add files to git

    $ git add CHANGELOG.md lib/pact/provider_verifier/version.rb

4. Commit

    $ git commit -m "Releasing version x.y.z"

3. Release:

      $ bundle exec rake release

4. Create standalone package

    # change to ruby 2.2 using your ruby manager
    bundle exec rake package

5. Draft a new [release](https://github.com/pact-foundation/pact-provider-verifier/releases/new) with name `pact-provider-verifier-x.y.z`

6. Open RELEASE.template and update the versions and copy this text into the release notes section.

6. Upload `.tar.gz` and `.zip` artifacts from `./pkg`
