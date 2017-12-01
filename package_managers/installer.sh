#!/bin/bash
set -ex
pushd tmp
tar -xvf installables.tar
dpkg -i *.deb
apt-get install -f
popd
umount -l /tmp/installer.sh
umount -l /tmp/installables.tar
rm -rf /tmp
