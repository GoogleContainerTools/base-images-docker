#!/bin/bash
set -ex

usage() {
  echo "Usage: $0 [SNAPSHOT] [VARIANT] [DIST]"
  echo
  echo "[SNAPSHOT]: The debian snapshot datetime to use."
  echo "[VARIANT]: The debian variant to use."
  echo "[DIST]: The debian dist to use."
  echo
  exit 1
}

if [ $# -ne 3 ]; then
    usage
fi

SNAPSHOT=$1
VARIANT=$2
DIST=$3

WORKDIR="/workspace/jessie"
mkdir -p "$WORKDIR"

debootstrap --variant="$VARIANT" "$DIST" "$WORKDIR" http://snapshot.debian.org/archive/debian/"$SNAPSHOT"

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

# Add the SNAPSHOT security and updates mirrors, for a final upgrade.
cat << EOF > $WORKDIR/etc/apt/sources.list
deb http://snapshot.debian.org/archive/debian/$SNAPSHOT $DIST main
deb http://snapshot.debian.org/archive/debian/$SNAPSHOT $DIST-updates main
deb http://snapshot.debian.org/archive/debian-security/$SNAPSHOT $DIST/updates main
EOF
rootfs_chroot apt-get -o Acquire::Check-Valid-Until=false update
rootfs_chroot apt-get -y -q upgrade

# Clean some apt artifacts
rootfs_chroot apt-get clean

# Reset the mirrors to distro-based ones
cat << EOF > $WORKDIR/etc/apt/sources.list
deb http://httpredir.debian.org/debian $DIST main
deb http://httpredir.debian.org/debian $DIST-updates main
deb http://security.debian.org $DIST/updates main
EOF

# Delete dirs we don't need, leaving the entries.
rm -rf "$WORKDIR"/dev "$WORKDIR"/proc
mkdir -p "$WORKDIR"/dev "$WORKDIR"/proc

rm -rf "$WORKDIR"/var/lib/apt/lists/snapshot*
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

# Hardcode this somewhere
rm -f "$WORKDIR"/etc/machine-id

# This gets overridden by Docker at runtime.
rm -f "$WORKDIR"/etc/hostname

# pass -n to gzip to strip timestamps
# strip the '.' with --transform that tar includes at the root to build a real rootfs
GZIP="-n" tar --numeric-owner -czf /workspace/rootfs.tar.gz -C "$WORKDIR" . --transform='s,^./,,' --mtime='1970-01-01'
md5sum /workspace/rootfs.tar.gz
