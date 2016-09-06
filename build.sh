#!/bin/bash
set -e
set -x
TAG=`date +%Y-%m-%d`
REPO=$1
cp -R third_party/docker/* mkdebootstrap/
cd mkdebootstrap && gcloud alpha container builds create . -t $REPO/mkdebootstrap:jessie
cd ..
cp -R third_party/docker/* docker-mkdebootstrap/
cd docker-mkdebootstrap && gcloud alpha container builds create . -t $REPO/docker-mkdebootstrap:jessie
cd ..
# need to escape forward slashes in the sed command
sed -i 's/\$REPO\$/'${REPO//\//\\\/}'/' cloudbuild.yaml
sed -i 's/\$TAG\$/'$TAG'/' cloudbuild.yaml
gcloud alpha container builds create . --config=cloudbuild.yaml
