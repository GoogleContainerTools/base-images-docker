#!/bin/bash
set -ex

# shellcheck source=/dev/null
source "$KOKORO_GFILE_DIR/common.sh"
"$KOKORO_GFILE_DIR/verify-commits.sh"
github/debian-docker/build.sh -r "$DOCKER_NAMESPACE" -v "$DEBIAN_SUITE"

