#!/bin/bash

set -ex

# Load utils
source %{util_script}

# Load the image and remember its name
image_id=$(sh %{image_id_extractor_path} %{image_tar})
docker load -i %{image_tar}

id=$(docker run -d $image_id %{commands})

reset_cmd $image_id $id %{output_image}

docker save %{output_image} -o %{output_tar}
docker rm $id
