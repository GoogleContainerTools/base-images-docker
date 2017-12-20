#!/bin/bash

set -ex

%{load_statement}

id=$(docker run -d %{image} %{commands})

# Attach can fail if the container has already stopped.
docker attach $id || true

docker commit $id %{output_image}
docker save %{output_image} -o %{output_tar}
docker rm $id
