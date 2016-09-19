#!/bin/bash
set -e
set -x
TAG=$(date +%Y-%m-%d)
REPO=$1
VERSION=$2
BUCKET=$3
GCLOUD_CMD="gcloud"
if [ -n "$4" ]
then
  GCLOUD_CMD=$4
fi

if [ "$VERSION" == "jessie" ]
then
  VERSION_NUMBER=8
else
  echo "Invalid version $VERSION"
  exit 1
fi

cp -R third_party/docker/mkimage* mkdebootstrap/

sed -i "s|%REPO%|$REPO|g" cloudbuild.yaml
sed -i "s|%TAG%|$TAG|g" cloudbuild.yaml
sed -i "s|%VERSION%|$VERSION|g" cloudbuild.yaml
sed -i "s|%NUM%|$VERSION_NUMBER|g" cloudbuild.yaml
$GCLOUD_CMD alpha container builds create . --config=cloudbuild.yaml --verbosity=info --gcs-source-staging-dir=gs://$BUCKET/staging --gcs-log-dir=gs://$BUCKET/logs
