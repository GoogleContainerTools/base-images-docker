#!/bin/bash
set -ex

usage() {
  echo "Usage: $0 [SNAPSHOT]"
  echo
  echo "[SNAPSHOT]: The debian snapshot datetime to use.."
  echo
  exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

SNAPSHOT=$1

WORKDIR="/workspace/jessie"
mkdir -p "$WORKDIR"

debootstrap --variant=minbase jessie "$WORKDIR" http://snapshot.debian.org/archive/debian/"$SNAPSHOT"

# Delete dirs we don't need.
rm -rf "$WORKDIR"/dev
rm -rf "$WORKDIR"/proc

# These are showing up as broken symlinks?
rm -rf "$WORKDIR"/usr/share/vim/vimrc
rm -rf "$WORKDIR"/usr/share/vim/vimrc.tiny

# Remove files with non-determinism
rm -rf "$WORKDIR"/var/cache/man
rm -rf "$WORKDIR"/var/cache/ldconfig/aux-cache
rm -rf "$WORKDIR"/var/log/dpkg.log
rm -rf "$WORKDIR"/var/log/bootstrap.log
rm -rf "$WORKDIR"/var/log/alternatives.log

# Hardcode this somewhere
rm "$WORKDIR"/etc/machine-id

# This gets overridden by Docker at runtime.
rm "$WORKDIR"/etc/hostname

# pass -n to gzip to strip timestamps
# strip the '.' with --transform that tar includes at the root to build a real rootfs
GZIP="-n" tar --numeric-owner -czf /workspace/rootfs.tar.gz -C "$WORKDIR" . --transform='s,^./,,' --mtime='1970-01-01'
md5sum /workspace/rootfs.tar.gz
