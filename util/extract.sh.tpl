#!/bin/bash

set -ex

# Load the image and remember its name
image_name=$(sh %{image_loader_path} %{image_tar})

id=$(docker run -d $image_name %{commands})

docker wait $id
docker cp $id:%{extract_file} %{output}
docker rm $id
