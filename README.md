# rclone-arangodb

This repository was made to deliver recompiled rclone versions included into
ArangoDB <MAJOR>.<MINOR> branches releases.

Each <MAJOR>.<MINOR> branch tied to the specific rclone version which cannot be
changed over time to remain backwards compatibility. However in case of any
additional CVEs there is a need to rebuild it with newer toolchain (either by
raising golang version or updating dependent components).

## How to make a release

### Prerequisites

In order to make a release with newer toolchain the following prerequisites are
required:
 - `git` latest stable version
 - `docker` latest stable version

### Steps

- create a commit with necessary changes if needed:
  - set `golang` version within `./toolchain.env`
  - check `<MAJOR>.<MINOR>` used rclone version in `rclone.env` and produced
    targets within `targets.env`
  - update `./make_release.sh` script in case dependant components of rclone
    must be upgraded
  - update ./release.env to set a release `<TIMESTAMP>`: `echo TIMESTAMP=$(date +%Y%m%d%H%M%S) > ./release.env`
- run `./make_release.sh` to produce necessary binaries:
  - `golang-<GO_VERSION>-<COMMIT>-<TIMESTAMP>` folder with necessary structure and binaries
    should be produced
- push local changes to GitHub
- make tagged release `golang-<GO_VERSION>-<COMMIT>` with artifacts and
  structure of the produced local folder of the tag's name
