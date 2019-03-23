#!/bin/bash

# This script sets up a bootstrapped CentOS chroot and saves it as a tarball.

mkdir /target
rpm --nodeps --root /target/ -i http://mirror.centos.org/centos/7/os/x86_64/Packages/centos-release-7-6.1810.2.el7.centos.x86_64.rpm
cp -f /etc/resolv.conf /target/etc

sed -i '/nodocs/d' /etc/yum.conf
yum -q -y --installroot=/target --releasever=7 install yum
cp -f /etc/yum.conf /target/etc/
mkdir -p /target/dev
mount --bind /dev/ /target/dev/
mount -t proc procfs /target/proc/
mount -t sysfs sysfs /target/sys/

# Execute the chroot script.
chroot /target ./chroot.sh

# Cleanup and save as a tar.
umount /target/dev/
umount /target/proc/
umount /target/sys/
rm /target/chroot.sh

tar -C /target -cf /workspace/layer.tar .


