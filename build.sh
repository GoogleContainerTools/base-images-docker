#!/bin/bash
set -e
set -x
TAG=$(date +%Y-%m-%d)
REPO=$1
VERSION=$2

cp -R third_party/docker/* mkdebootstrap/
cp -R third_party/docker/* docker-mkdebootstrap/

sed -i "s|%REPO%|$REPO|g" cloudbuild.yaml
sed -i "s|%TAG%|$TAG|g" cloudbuild.yaml
sed -i "s|%VERSION%|$VERSION|g" cloudbuild.yaml
gcloud alpha container builds create . --config=cloudbuild.yaml
