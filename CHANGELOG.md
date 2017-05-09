Do this to generate your change history

  git log --pretty=format:'  * %h - %s (%an, %ad)' vX.Y.Z..HEAD

### 1.0.0 (9 May 2017)
* 94597a0 - Updated pact gem to allow use of https for publishing verifications (Beth Skurrie, Tue May 9 14:27:19 2017 +1000)

### 0.0.4 (15 May 2016)

* c5dc292 - Added basic authentication support for Pact Broker URLs (Matt Fellows, Sun May 15 19:08:22 2016 +1000)

### 0.0.3 (15 May 2016)

* d36ae19 - Release v0.0.3 (Matt Fellows, Sun May 15 11:22:41 2016 +1000)

### 0.0.2 (12 May 2016)

* 0aca507 - Refactored to not use the Pact rake tasks. Traveling Ruby does not like shelling out to a Ruby process (where's my Gems?) (Matt Fellows, Thu May 12 21:55:29 2016 +1000)
* 9feb60e - Verifier properly runs all Pacts provided and handles Pact CLI exit call (Matt Fellows, Sun May 15 11:22:12 2016 +1000)
* a85903d - Release template (Matt Fellows, Thu May 12 21:53:22 2016 +1000)
* 059b488 - Setting execute perms on wrapper script during package (Matt Fellows, Thu May 12 22:30:22 2016 +1000)

### 0.0.1 (8 May 2016)

* 39e75f3 - Pact provider verifier cross-platform CLI tool (Matt Fellows, Thu May 12 07:30:47 2016 +1000)
