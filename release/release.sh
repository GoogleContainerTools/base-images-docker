#!/bin/bash
set -ex

# shellcheck disable=SC1090
source "$KOKORO_GFILE_DIR/common.sh"
sudo chmod +x "$KOKORO_GFILE_DIR/verify-commits.sh"
"$KOKORO_GFILE_DIR"/verify-commits.sh
cd github/debian-docker
./build.sh -r "$DOCKER_NAMESPACE" -v "$DEBIAN_SUITE"

