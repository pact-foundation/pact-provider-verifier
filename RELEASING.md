# Releasing

1. Increment the version according to semantic versioning rules in `lib/pact/provider_verifier/version.rb`

2. Update the `CHANGELOG.md` using:

    $ git log --pretty=format:'  * %h - %s (%an, %ad)' vX.Y.Z..HEAD

3. Add files to git

    $ git add CHANGELOG.md lib/pact/provider_verifier/version.rb

4. Commit

    $ git commit -m "Releasing version X.Y.Z"

5. Tag

    $ git tag -a vX.Y.Z -m "Releasing version X.Y.Z" && git push origin --tags

6. Wait until travis has run and uploaded the build artifacts to https://github.com/pact-foundation/pact-provider-verifier/releases/tag/vX.Y.Z

7. Set the title to `pact-provider-verifier-X.Y.Z`

8. Open RELEASE.template and update the versions and copy this text into the release notes section.

9. Save
