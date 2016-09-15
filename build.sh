#!/bin/bash
set -e
set -x
TAG=$(date +%Y-%m-%d)
REPO=$1
VERSION=$2
GCLOUD_CMD="gcloud"
if [ -n "$3" ]
then
  GCLOUD_CMD=$3
fi

cp -R third_party/docker/mkimage* mkdebootstrap/

sed -i "s|%REPO%|$REPO|g" cloudbuild.yaml
sed -i "s|%TAG%|$TAG|g" cloudbuild.yaml
sed -i "s|%VERSION%|$VERSION|g" cloudbuild.yaml
$GCLOUD_CMD alpha container builds create . --config=cloudbuild.yaml
