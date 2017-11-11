# Releasing

## Code release

Run `script/release.sh [major|minor|patch]` #defaults to minor

## Repackaging release

1. Set the package number (eg. "-1") in `tasks/package.rake`. This is required because the same gem version may be packaged multiple times.
1. Run the rest of the commands from release.sh manually.
