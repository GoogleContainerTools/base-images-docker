#!/bin/bash
# Temp step to get around Argo not running docker commands in privileged mode.
# Will be fixed with b/31267381.
set -e
set -x
apiversion=1.21
export DOCKER_API_VERSION="$apiversion"
TAG=`date +%Y-%m-%d`
docker run --name mkdebootstrap --privileged --volume /workspace gcr.io/sharif-test/mkdebootstrap:jessie -d /workspace --compression bz2 debootstrap --variant=minbase jessie
docker cp mkdebootstrap:/workspace/rootfs.tar.bz2 /workspace
docker rm --volumes mkdebootstrap
