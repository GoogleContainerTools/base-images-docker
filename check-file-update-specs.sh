#!/bin/bash
set -ex

# Run the file update spec syntax checker on the base image file_update.yaml
# files.
specs=(
  "centos7/file_updates.yaml"
  "ubuntu1604/file_updates.yaml"
  "debian9/file_updates.yaml"
  "ubuntu1804/file_updates.yaml"
)

for s in "${specs[@]}"
do
 docker run -v $PWD/$s:/workspace/$s \
   gcr.io/asci-toolchain/container_release_tools/file_update/validators/syntax \
   -logtostderr=true -specFile=/workspace/$s
done
