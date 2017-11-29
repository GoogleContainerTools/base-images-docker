#!/bin/bash
set -ex
tar -xvf installables.tar
tar -xvf installables.tar
rm installables.tar
dpkg -i *.deb
apt-get install -f
