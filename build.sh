#!/bin/bash

usage() {
  echo "Usage: $0 [-r repository] [-v version] [-c config]"
  echo
  echo "[repository]: remote repository to push the debian image to (e.g. 'gcr.io/gcp-runtimes/debian')"
  echo "[version]: version of debian to build (e.g. 'jessie')"
  echo "[config]: the yaml file defining the steps of the build, defaults to cloudbuild.yaml"
  echo
  exit 1
}

set -e
if [ -z "$TAG" ]
then
  TAG=$(date +%Y-%m-%d-%H%M%S)
  export TAG
fi

CONFIG=reproducible/cloudbuild.yaml

while test $# -gt 0; do
  case "$1" in
          --repo|--repository|-r)
                  shift
                  if test $# -gt 0; then
                          REPO=$1
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
          --config|-c)
                  shift
                  if test $# -gt 0; then
                          CONFIG=$1
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

if [ -z "$REPO" ] || [ -z "$VERSION" ]; then
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

gcloud container builds submit . --config="$CONFIG" --verbosity=info --substitutions=_REPO="$REPO",_TAG="$TAG",_VERSION_NUMBER="$VERSION_NUMBER"
