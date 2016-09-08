#!/bin/bash
# Container builder doesn't currently run in privileged mode so this script runs
# docker inside docker to allow privileged mode so debootstrap can run chroot.
# Once container builder allows privileged mode, this script will go away.
set -e
set -x
apiversion=1.21
export DOCKER_API_VERSION="$apiversion"
printenv
REPO=$1
VERSION=$2
docker run --name mkdebootstrap --privileged --volume /workspace $REPO/mkdebootstrap:jessie -d /workspace --compression bz2 debootstrap --variant=minbase $VERSION
docker cp mkdebootstrap:/workspace/rootfs.tar.bz2 /workspace
docker rm --volumes mkdebootstrap
