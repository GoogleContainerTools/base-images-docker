#!/bin/bash
# shellcheck disable=SC2115
set -ex

usage() {
  echo "Usage: $0 [VARIANT] [DIST]"
  echo
  echo "[VARIANT]: The debian variant to use."
  echo "[DIST]: The debian dist to use."
  echo
  exit 1
}

if [ $# -ne 2 ]; then
    usage
fi

VARIANT=$1
DIST=$2

WORKDIR="/workspace/$DIST"
mkdir -p "$WORKDIR"

debootstrap --variant="$VARIANT" "$DIST" "$WORKDIR" http://httpredir.debian.org/debian

rootfs_chroot() {
    PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
        chroot "$WORKDIR" "$@"
}

# Add some tools we need.
rootfs_chroot apt-get install -y --no-install-recommends \
  netbase \
  ca-certificates

# We have our own version of initctl, tell dpkg to not overwrite it.
rootfs_chroot dpkg-divert --local --rename --add /sbin/initctl

# Set the mirrors to distro-based ones
cat << EOF > $WORKDIR/etc/apt/sources.list
deb http://httpredir.debian.org/debian $DIST main
deb http://httpredir.debian.org/debian $DIST-updates main
deb http://security.debian.org $DIST/updates main
EOF

# Do a final upgrade.
rootfs_chroot apt-get -o Acquire::Check-Valid-Until=false update
rootfs_chroot apt-get -y -q upgrade

# Clean some apt artifacts
rootfs_chroot apt-get clean

# Delete dirs we don't need, leaving the entries.
rm -rf "${WORKDIR:?}"/dev "$WORKDIR"/proc
mkdir -p "$WORKDIR"/dev "$WORKDIR"/proc

rm -rf "$WORKDIR"/var/lib/apt/lists/httpredir*
rm -rf "$WORKDIR"/etc/apt/apt.conf.d/01autoremove-kernels

# These are showing up as broken symlinks?
rm -rf "$WORKDIR"/usr/share/vim/vimrc
rm -rf "$WORKDIR"/usr/share/vim/vimrc.tiny

# Remove files with non-determinism
rm -rf "$WORKDIR"/var/cache/man
rm -rf "$WORKDIR"/var/cache/ldconfig/aux-cache
rm -rf "$WORKDIR"/var/log/dpkg.log
rm -rf "$WORKDIR"/var/log/bootstrap.log
rm -rf "$WORKDIR"/var/log/alternatives.log
rm -rf "$WORKDIR"/var/log/apt/history.log
rm -rf "$WORKDIR"/var/log/apt/term.log

# Hardcode this somewhere
rm -f "$WORKDIR"/etc/machine-id

# This gets overridden by Docker at runtime.
rm -f "$WORKDIR"/etc/hostname

# pass -n to gzip to strip timestamps
# strip the '.' with --transform that tar includes at the root to build a real rootfs
GZIP="-n" tar --numeric-owner -czf /workspace/rootfs.tar.gz -C "$WORKDIR" . --transform='s,^./,,' --mtime='1970-01-01'
md5sum /workspace/rootfs.tar.gz
