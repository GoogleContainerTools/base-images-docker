#!/bin/bash

set -ex

# Load the image and remember its name
image_id=$(sh %{image_id_extractor_path} %{image_tar})
docker load -i %{image_tar}

id=$(docker run -d $image_id %{commands})

docker wait $id
docker cp $id:%{extract_file} %{output}
docker rm $id
