#!/bin/bash
# This script installs debs in installables.tar through dpkg and apt-get.
# It expects to be volume-mounted inside a docker image, in /tmp along with the
# installables.tar.
set -ex
pushd /tmp
tar -xvf installables.tar
dpkg -i *.deb
apt-get install -f
popd
umount -l /tmp/installer.sh
umount -l /tmp/installables.tar
rm -rf /tmp
