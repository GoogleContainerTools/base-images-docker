#!/bin/bash

# This script sets up a bootstrapped CentOS chroot and saves it as a tarball.

rpm --nodeps --root /target/ -i /centos.rpm
cp -f /etc/resolv.conf /target/etc

sed -i '/nodocs/d' /etc/yum.conf
yum -q -y --installroot=/target --releasever=${1} install yum
cp -f /etc/yum.conf /target/etc/
mkdir -p /target/dev
mount --bind /dev/ /target/dev/
mount -t proc procfs /target/proc/
mount -t sysfs sysfs /target/sys/

# Execute the chroot script.
chroot /target ./chroot.sh ${1}

# Cleanup and save as a tar.
yum clean all
echo 'container' > /etc/yum/vars/infra
rm -rf /var/lib/systemd/random-seed
#rpm --rebuilddb

umount /target/dev/
umount /target/proc/
umount /target/sys/
rm /target/chroot.sh
echo 7 > /target/etc/yum/vars/releasevar

tar -C /target --mtime='1970-01-01' -cf /layer.tar .
