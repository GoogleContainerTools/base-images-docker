#!/bin/bash
# The debootstrap execution itself can't run in bazel because of sandboxing.
# So, we use a genrule to call docker to build the tarball and output it.


usage() {
  echo "Usage: $0 [output_file] [snapshot]"
  echo
  echo "[output_file]: The path to output the rootfs (.tar.gz) into."
  echo "[snapshot]: The debian snapshot to use."
  echo
  exit 1
}

set -ex

if [ $# -ne 2 ]; then
    usage
fi

# Resolve symlinks for the docker build.
tmpdir=$(mktemp -d)
cp repeatable/* "$tmpdir"

docker rm builder-container || true
# We need to do the build in a debian container that has debootstrap
docker run --name=builder-container --privileged bazel/repeatable:builder /mkimage.sh "$2"

# Copy out the generated rootfs
docker cp builder-container:/tmp/rootfs.tar.gz "$1"
docker rm builder-container || true
