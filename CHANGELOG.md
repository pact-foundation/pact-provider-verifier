Do this to generate your change history

  git log --pretty=format:'  * %h - %s (%an, %ad)' vX.Y.Z..HEAD

# Release process

* Bump version and update this changelog
* `bundle exec rake package`
* open `./pkg`
* Draft a new [release](https://github.com/pact-foundation/pact-provider-verifier/releases/new)
  * Set name to `pact-provider-verifier-x.y.z`
  * Upload artifacts from `./pkg`

### 0.0.1 (8 May 2016)

* 39e75f3 - Pact provider verifier cross-platform CLI tool (Matt Fellows, Thu May 12 07:30:47 2016 +1000)
