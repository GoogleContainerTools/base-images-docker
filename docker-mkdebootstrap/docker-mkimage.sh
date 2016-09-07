#!/bin/bash
# Cloud build doesn't currently run in privileged mode so this script runs
# docker inside docker to allow privileged mode so debootstrap can run chroot.
# Once cloud build allows privileged mode, this script will go away.
set -e
set -x
apiversion=1.21
export DOCKER_API_VERSION="$apiversion"
TAG=`date +%Y-%m-%d`
docker run --name mkdebootstrap --privileged --volume /workspace gcr.io/sharif-test/mkdebootstrap:jessie -d /workspace --compression bz2 debootstrap --variant=minbase jessie
docker cp mkdebootstrap:/workspace/rootfs.tar.bz2 /workspace
docker rm --volumes mkdebootstrap
