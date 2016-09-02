#!/bin/bash
set -e
set -x
apiversion=1.21
export DOCKER_API_VERSION="$apiversion"
TAG=`date +%Y-%m-%d`
docker run --name mkdebootstrap --privileged --volume /workspace gcr.io/sharif-test/mkdebootstrap:$TAG -d /workspace --compression bz2 debootstrap --variant=minbase jessie
docker cp mkdebootstrap:/workspace/rootfs.tar.bz2 /workspace
docker rm --volumes mkdebootstrap
