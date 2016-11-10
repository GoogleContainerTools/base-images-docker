#!/bin/bash

usage() {
  echo "Usage: $0 [-r repository] [-v version] [-b bucket] [-c command]"
  echo
  echo "[repository]: remote repository to push the debian image to (e.g. 'gcr.io/gcp-runtimes/debian')"
  echo "[version]: version of debian to build (e.g. 'jessie')"
  echo "[bucket]: GCS bucket to push staging images"
  echo "[command]: optional gcloud command"
  echo
  exit 1
}

set -e
if [ -z "$TAG" ]
then
  TAG=$(date +%Y-%m-%d-%H%M%S)
  export TAG
fi

GCLOUD_CMD="gcloud"

while test $# -gt 0; do
  case "$1" in
          --repo|--repository|-r)
                  shift
                  if test $# -gt 0; then
                          export REPO=$1
                  else
                          usage
                  fi
                  shift
                  ;;
          --version|-v)
                  shift
                  if test $# -gt 0; then
                          export VERSION=$1
                  else
                        usage
                  fi
                  shift
                  ;;
          --bucket|-b)
                  shift
                  if test $# -gt 0; then
                          export BUCKET=$1
                  else
                          usage
                  fi
                  shift
                  ;;
          --command|-c)
                  shift
                  if test $# -gt 0; then
                          GCLOUD_CMD=$1
                  else
                          usage
                  fi
                  shift
                  ;;
          *)
                  usage
                  shift
                  ;;
  esac
done

if [ -z "$REPO" ] || [ -z "$VERSION" ] || [ -z "$BUCKET" ]; then
  usage
fi

if [ "$VERSION" == "jessie" ]
then
  export VERSION_NUMBER=8
elif [ "$VERSION" == "stretch" ]
then
  export VERSION_NUMBER=9
else
  echo "Invalid version $VERSION"
  usage
fi

cp -R third_party/docker/mkimage* mkdebootstrap/

envsubst < cloudbuild.yaml.in > cloudbuild.yaml
envsubst < mkdebootstrap/Dockerfile.in > mkdebootstrap/Dockerfile
$GCLOUD_CMD alpha container builds create . --config=cloudbuild.yaml --verbosity=info --gcs-source-staging-dir="gs://$BUCKET/staging" --gcs-log-dir="gs://$BUCKET/logs"
