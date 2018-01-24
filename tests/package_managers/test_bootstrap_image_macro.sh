#!/bin/bash

set -ex

trap __cleanup EXIT

#Clean up functions
__cleanup ()
{
  [[ -d "$TEST_GIT_REPO" ]] && rm -rf "$TEST_GIT_REPO"
}

PWD=$(pwd)
GIT_ROOT=$(git rev-parse --show-toplevel)

if [ "$PWD" != "$GIT_ROOT" ]; then
  echo "Please run this script from bazel root workspace"
  exit 1
fi

TEST_GIT_REPO="tests/package_managers/tmp_git"
TEST_STORE="$TEST_GIT_REPO/ubuntu/builds"
TEST_SCRIPT_CMD="./bootstrap_image.sh -t tests/package_managers:bootstrap_ubuntu -g $PWD/$TEST_GIT_REPO"
DATE="2017/12/15"

# Create a Temporary store in this directory
mkdir -p "$TEST_STORE"

# Run Bazel build target for first time
bazel clean
OUTPUT=$($TEST_SCRIPT_CMD)

# Check if download_pkgs output was ran
EXPECTED_OUTPUT="*Running download_pkgs script*"
if [ "${OUTPUT/$EXPECTED_OUTPUT}" = "$OUTPUT" ] ; then
  echo "Expected download_pkgs script to run. However it did not"
  exit 1
else
  echo "download_pkgs script ran as expected"
fi

# Test if downloaded pakcages.tar is copied to the store
PUT_FILE="$GIT_ROOT/$TEST_STORE/$DATE/packages.tar"
if [ ! -f "$PUT_FILE" ]; then
   echo "Expected file $PUT_FILE to be present. However its not."
   exit 1
fi

# Run Bazel build target once again and this time download_pkgs script should
# not run
bazel clean
OUTPUT=$($TEST_SCRIPT_CMD)
# Check if download_pkgs output was ran
if [ "${OUTPUT/$EXPECTED_OUTPUT}" = "$OUTPUT_2" ] ; then
  echo "download_pkgs script did not run as expected"
else
  echo "download_pkgs script ran. However it should not have!"
  exit 1
fi

