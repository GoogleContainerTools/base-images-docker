#!/bin/bash
# shellcheck disable=SC2086

set -ex

usage() {
  echo "Usage: $0 [VERSION] [NODE_OUTPUT_TAR]"
  echo
  echo "[VERSION]: The semvar version of node to build ex: v8.5.0 ."
  echo "[NODE_OUTPUT_PATH]: The path to output the compiled node rootfs."
  echo
  exit 1
}

if [ $# -ne 2 ]; then
    usage
fi

VERSION=$1
NODE_OUTPUT_PATH=$2

IMG_NAME=$("docker load -i $(pwd)/dockerfile_build/ubuntu_build.tar | awk '{print $3}'")

# Run the base image.
CID=$("docker run -d -v $(pwd)/reproducible/ubuntu/mknodeimage.sh:/mknodeimage.sh $IMG_NAME /mknodeimage.sh $VERSION")
docker attach "$CID"
# Copy out the nodejs tar.
docker cp $CID:/workspace/node_"$VERSION"_compiled.tar.gz "$NODE_OUTPUT_PATH"

# Cleanup
docker rm "$CID"
