#!/bin/bash

set -ex

PWD=`pwd`
GIT_ROOT=`git rev-parse --show-toplevel`

if [ "$PWD" != "$GIT_ROOT" ]; then
  echo "Please run this script from bazel root workspace"
  exit 1
fi

TEST_STORE="tests/package_managers/tmp_git/ubuntu/builds"
TEST_SCRIPT_CMD="./bootstrap_image.sh -t tests/package_managers:bootstrap_ubuntu"
DATE="2017/12/15"

# Create a Temporary store in this directory
mkdir -p "$TEST_STORE"

# Run Bazel build target for first time
bazel clean
OUTPUT=source $TEST_SCRIPT_CMD
EXPTECTED_OUTPUT="Running download_pkgs script"
# Check if download_pkgs output was ran
if [ "${OUTPUT/$EXPECTED_OUTPUT}" = "$OUTPUT" ] ; then
    echo "Expected download_pkgs script ran!!"
else
    echo "Expected download_pkgs script to run. However it did not"
    exit 1
fi

# Test if downloaded pakcages.tar is copied to the store

# Run Bazel build target once again and this time download_pkgs script should
# not run
bazel clean
OUTPUT=source $TEST_SCRIPT_CMD
EXPTECTED_OUTPUT="Running download_pkgs script"
# Check if download_pkgs output was ran
if [ "${OUTPUT/$EXPECTED_OUTPUT}" = "$OUTPUT" ] ; then
  echo "download_pkgs script ran but should not have"
  exit 1
else
  echo "Expected download_pkgs script not to run."
fi

trap __cleanup EXIT

#Clean up functions
__cleanup ()
{
    [[ -d "$TEST_STORE" ]] && rm -rf "$TEST_STORE"
}

