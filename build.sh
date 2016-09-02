#!/bin/bash
set -e
set -x
TAG=`date +%Y-%m-%d`
cd mkdebootstrap && gcloud alpha container builds create . -t gcr.io/sharif-test/mkdebootstrap:$TAG
cd ../docker-mkdebootstrap && gcloud alpha container builds create . -t gcr.io/sharif-test/docker-mkdebootstrap:$TAG
cd ..
sed -i 's/\$REPLACEME\$/'$TAG'/' cloudbuild.yaml
gcloud alpha container builds create . --config=cloudbuild.yaml
