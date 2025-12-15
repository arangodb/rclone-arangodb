#!/bin/bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd ${SCRIPT_DIR}
. ./toolchain.env
. ./release.env

printf "Making release of rclone for ArangoDB with $GO_VERSION...\n\n"

RELEASE_TAG="${GO_VERSION//:/-}-$(git rev-parse --short HEAD)_$TIMESTAMP"
RELEASE_OUTPUT=${SCRIPT_DIR}/${RELEASE_TAG}
rm -rf ${RELEASE_OUTPUT} && mkdir -p ${RELEASE_OUTPUT}

for ARANGODB in $(echo 3.*)
do
  cd ${SCRIPT_DIR}/${ARANGODB}

  . ./rclone.env

  printf "Making release of rclone for ArangoDB $ARANGODB...\n\n"

  . ./targets.env
  rm -rf ./rclone && \
  git clone --single-branch --depth 1 -b ${RCLONE_VERSION} https://github.com/arangodb/rclone-update.git rclone && cd ./rclone

  for TARGET in ${TARGETS}
  do
    TARGET_OS="${TARGET%_*}"
    TARGET_ARCH="${TARGET#*_}"
    printf "Building rclone $RCLONE_VERSION for $TARGET_OS-$TARGET_ARCH...\n\n"continue
    docker run --rm -v "$(pwd):/rclone" \
      -v "${HOME}:/user" \
      -e "GOPATH=/user/rclone_go/go" \
      -e "GOCACHE=/user/rclone_go/cache" \
      -e "RCLONE_OUTPUT=${RELEASE_TAG}_${ARANGODB}_${RCLONE_VERSION}" \
      -e "TARGET_OS=$TARGET_OS" \
      -e "TARGET_ARCH=$TARGET_ARCH" \
      -u "${UID}:${GID}" \
      -w /rclone ${GO_VERSION} \
      bash +x -c 'cd /rclone; go mod vendor; go mod tidy; go mod vendor; function build { GOOS=$1 GOARCH=$2 CGO_ENABLED=0 go build -trimpath -ldflags="-s -w -X github.com/rclone/rclone/fs.VersionSuffix= " -tags cmount -o /rclone/${RCLONE_OUTPUT}_rclone-arangodb-$(echo $1 | sed "s/darwin/macos/g")-$2$([[ $1 == "windows" ]] && echo ".exe"); }; build $TARGET_OS $TARGET_ARCH' && \
      mv ./*rclone-arangodb-*-* "${RELEASE_OUTPUT}" && rm -rf ./*rclone-arangodb-*-*
    printf "\n\nDone building rclone $RCLONE_VERSION for $TARGET_OS-$TARGET_ARCH!\n\n"
  done
  printf "\n\nDone making release of rclone for ArangoDB $ARANGODB!\n\n"
  rm -rf ${SCRIPT_DIR}/${ARANGODB}/rclone
done

printf "\n\nDone making release of rclone for ArangoDB with $GO_VERSION!\n\n"
