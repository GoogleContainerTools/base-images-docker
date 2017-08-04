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

JESSIE="/tmp/jessie"
mkdir "$JESSIE"

debootstrap jessie "$JESSIE" http://snapshot.debian.org/archive/debian/"$SNAPSHOT"

# Delete dirs we don't need.
rm -rf "$JESSIE"/dev
rm -rf "$JESSIE"/proc

# These are showing up as broken symlinks?
rm -rf "$JESSIE"/usr/share/vim/vimrc
rm -rf "$JESSIE"/usr/share/vim/vimrc.tiny

# Remove files with non-determinism
rm -rf "$JESSIE"/var/cache/man
rm -rf "$JESSIE"/var/cache/ldconfig/aux-cache
rm -rf "$JESSIE"/var/log/dpkg.log
rm -rf "$JESSIE"/var/log/bootstrap.log
rm -rf "$JESSIE"/var/log/alternatives.log

# Hardcode this somewhere
rm "$JESSIE"/etc/machine-id

# This gets overridden by Docker at runtime.
rm "$JESSIE"/etc/hostname

# pass -n to gzip to strip timestamps
# strip the '.' with --transform that tar includes at the root to build a real rootfs
GZIP="-n" tar --numeric-owner -czf /tmp/rootfs.tar.gz -C "$JESSIE" . --transform='s,^./,,' --mtime='1970-01-01'
md5sum /tmp/rootfs.tar.gz
