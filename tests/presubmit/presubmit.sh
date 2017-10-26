#!/bin/bash
set -ex
# shellcheck source=/dev/null
source "$KOKORO_GFILE_DIR/common.sh"
sudo chmod +x "$KOKORO_GFILE_DIR/verify-commits.sh"
"$KOKORO_GFILE_DIR"/verify-commits.sh

# Grab the latest version of shellcheck and add it to PATH
wget https://storage.googleapis.com/shellcheck/shellcheck-latest.linux.x86_64.tar.xz
tar -xf shellcheck-latest.linux.x86_64.tar.xz
sudo cp shellcheck-latest/shellcheck /usr/local/bin

cd github/debian-docker
# This is what travis currently does. Let's test what's faster.
make test
