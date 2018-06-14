#!/bin/bash

set -ex

# Load utils
source %{util_script}

# Load the image and remember its name
image_name=$(sh %{image_loader_path} %{image_tar})

id=$(docker run -d $image_name %{commands})

reset_cmd $image_name $id %{output_image}

docker save %{output_image} -o %{output_tar}
docker rm $id
