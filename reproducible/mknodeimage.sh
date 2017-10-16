#!/bin/bash
set -ex

WORKDIR="/workspace/nodejs_build"
OUTPUTDIR="$WORKDIR/nodejs"
mkdir -p "$OUTPUTDIR"
cd "$WORKDIR"

tar -xvf /node-v6.11.4.tar.gz
cd node-v6.11.4
./configure --prefix="$OUTPUTDIR"
make -j4
make install

# pass -n to gzip to strip timestamps
# strip the '.' with --transform that tar includes at the root to build a real rootfs
GZIP="-n" tar --numeric-owner -czf /workspace/rootfs.tar.gz -C "$OUTPUTDIR" . --transform='s,^./,,' --mtime='1970-01-01'
md5sum /workspace/rootfs.tar.gz
