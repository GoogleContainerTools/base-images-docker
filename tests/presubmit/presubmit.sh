#!/bin/bash
set -ex
# shellcheck source=/dev/null
source "$KOKORO_GFILE_DIR/common.sh"
cd github/debian-docker
test_tag="debian-kokoro-presubmit-$KOKORO_BUILD_NUMBER"
TAG=$test_tag ./build.sh -r gcr.io/gcp-runtimes -v "$DEBIAN_SUITE" -b gcp-runtimes_cloudbuild
