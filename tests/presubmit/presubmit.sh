#!/bin/bash
set -ex
# shellcheck disable=SC1090
source "$KOKORO_GFILE_DIR/common.sh"
sudo chmod +x "$KOKORO_GFILE_DIR/verify-commits.sh"
"$KOKORO_GFILE_DIR"/verify-commits.sh
sudo apt-get install shellcheck

cd github/debian-docker
# This is what travis currently does. Let's test what's faster.
make test
