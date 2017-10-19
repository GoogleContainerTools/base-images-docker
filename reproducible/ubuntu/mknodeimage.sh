#!/bin/bash
set -ex

VERSION=$1

ln -s /usr/bin/python2.7 /usr/bin/python

WORKDIR="/workspace/nodejs_build"
OUTPUTDIR="$WORKDIR/nodejs"
mkdir -p "$OUTPUTDIR"
cd "$WORKDIR"

NPROCS="$(grep -c ^processor /proc/cpuinfo)"
MAX_PROCS="4"

tar -xvf "/node-v$VERSION.tar.gz"
cd "node-v$VERSION"
./configure --prefix="$OUTPUTDIR"
# Sets number of cores to use for make, maximum of 4
make -j$(($NPROCS>$MAX_PROCS?$NPROCS:$MAX_PROCS)) &> /dev/null
make install &> /dev/null

# pass -n to gzip to strip timestamps
# strip the '.' with --transform thatp tar includes at the root to build nodejs
GZIP="-n" tar --numeric-owner -czf /workspace/nodejs.tar.gz -C "$OUTPUTDIR" . --transform='s,^./,,' --mtime='1970-01-01'
