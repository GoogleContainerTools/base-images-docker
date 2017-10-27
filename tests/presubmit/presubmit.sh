#!/bin/bash
set -ex
# shellcheck source=/dev/null
source "$KOKORO_GFILE_DIR/common.sh"
sudo chmod +x "$KOKORO_GFILE_DIR/verify-commits.sh"

# Grab the latest version of shellcheck and add it to PATH
sudo cp "$KOKORO_GFILE_DIR"/shellcheck-latest.linux /usr/local/bin/shellcheck
sudo chmod +x /usr/local/bin/shellcheck

# Maybe grab and configure the bazel cacher
if [ -e "$KOKORO_GFILE_DIR"/bazel-cache-gcs ]; then
    sudo cp "$KOKORO_GFILE_DIR"/bazel-cache-gcs /usr/local/bin/
    sudo chmod +x /usr/local/bin/bazel-cache-gcs
    bazel-cache-gcs --bucket=gcp-bazel-cache --verbosity=info --port=8081 &
    cat << EOF > "$HOME"/.bazelrc
startup --host_jvm_args=-Dbazel.DigestFunction=SHA1
build --spawn_strategy=remote
build --remote_rest_cache=http://localhost:8081/
# Bazel currently doesn't support remote caching in combination with workers.
# These two lines override the default strategy for Javac and Closure
# actions, so that they are also remotely cached.
# Follow https://github.com/bazelbuild/bazel/issues/3027 for more details:
build --strategy=Javac=remote
build --strategy=Closure=remote
EOF

fi

cd github/debian-docker
# This is what travis currently does. Let's test what's faster.
make test

"$KOKORO_GFILE_DIR"/verify-commits.sh