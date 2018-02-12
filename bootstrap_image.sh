#!/bin/bash
set -xe

# This script kicks of the bootstrap image macro with the right flags.

while getopts t:g:d option
do
 case "${option}"
 in
 t) TARGET=${OPTARG};;
 g) GIT_ROOT=${OPTARG};;
 d) DEBUG="--verbose_failures --sandbox_debug";;
 *) echo "Invalid option"; exit 1;;
 esac
done

# Error out if -t does not exists
if [ -z "${TARGET}" ];  then
  echo """
$(basename "$0") <Mandatory_args> <Optional_args>
Mandatory Args
 -t <bootstrap_image_macro>
Optional Args
 -g <git_root> Local Git root location
 -d Add debug options to bazel command
"""
  exit 1
fi

if [ -z "${GIT_ROOT}" ]; then
  GIT_ROOT=$(git rev-parse --show-toplevel)
fi

echo "Running bazel build ${TARGET}"
# shellcheck disable=SC2086
bazel build "${TARGET}" \
  --action_env=GIT_ROOT="${GIT_ROOT}" \
  --sandbox_writable_path="${GIT_ROOT}" ${DEBUG}

# get rid of running this once we figure out how to make put_status output mandatory in bootstrap_image.
echo "Running bazel build ${TARGET}_fetch to make we store the downloaded packages in the store back"
# shellcheck disable=SC2086
bazel build "${TARGET}_fetch" \
  --action_env=GIT_ROOT="${GIT_ROOT}" \
  --sandbox_writable_path="${GIT_ROOT}" ${DEBUG}

echo "Please run 'git status' and 'git commit' commands to commit  the downloaded packages to the git repository"
