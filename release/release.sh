#!/bin/bash
set -ex

source "$KOKORO_GFILE_DIR/common.sh"
$KOKORO_GFILE_DIR/verify-commits.sh
cd github/debian-docker
./build.sh -r $DOCKER_NAMESPACE -v $DEBIAN_SUITE

