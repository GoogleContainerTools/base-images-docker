#!/bin/bash
set -e
set -x
if [ -z "$TAG" ]
then
  export TAG=$(date +%Y-%m-%d)
fi
export REPO=$1
export VERSION=$2
export BUCKET=$3
GCLOUD_CMD="gcloud"
if [ -n "$4" ]
then
  GCLOUD_CMD=$4
fi

if [ "$VERSION" == "jessie" ]
then
  export VERSION_NUMBER=8
else
  echo "Invalid version $VERSION"
  exit 1
fi

cp -R third_party/docker/mkimage* mkdebootstrap/

envsubst '${REPO} ${TAG} ${VERSION} ${VERSION_NUMBER}' <cloudbuild.yaml.in >cloudbuild.yaml
$GCLOUD_CMD alpha container builds create . --config=cloudbuild.yaml --verbosity=info --gcs-source-staging-dir=gs://$BUCKET/staging --gcs-log-dir=gs://$BUCKET/logs
