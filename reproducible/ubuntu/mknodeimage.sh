#!/bin/bash
set -ex

# mknodeimage.sh
# USE: Downloads and compiles nodejs for the specified version
# ARGS: "[VERSION]: The semvar version of node to build ex: v8.5.0 ."

usage() {
  echo "Usage: $0 [VERSION]"
  echo
  echo "[VERSION]: The semvar version of node to build ex: v8.5.0 ."
  echo
  exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

VERSION=$1

WORKDIR="/workspace/nodejs_build"
OUTPUTDIR="$WORKDIR/nodejs"
mkdir -p "$OUTPUTDIR"
cd "$WORKDIR"

NPROCS="$(grep -c ^processor /proc/cpuinfo)"
MAX_PROCS="8"

# TODO(aprindle) add SHA verification
curl -O "https://nodejs.org/dist/$VERSION/node-$VERSION.tar.gz"

tar -xvf "node-$VERSION.tar.gz"
cd "node-$VERSION"
./configure --prefix="$OUTPUTDIR" &> /dev/null
# Sets number of cores to use for make, maximum of 4
make -j$((NPROCS>MAX_PROCS?MAX_PROCS:NPROCS)) &> /dev/null
make install &> /dev/null

# pass -n to gzip to strip timestamps
# strip the '.' with --transform thatp tar includes at the root to build nodejs
GZIP="-n" tar --numeric-owner -czf /workspace/node_"$VERSION"_compiled.tar.gz -C "$OUTPUTDIR" . --transform='s,^./,,' --mtime='1970-01-01'
