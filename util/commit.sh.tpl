#!/bin/bash

set -ex

%{load_statement}

id=$(docker run -d %{flags} %{image} %{commands})

docker commit $id %{output_image}
docker save %{output_image} -o %{output_tar}
docker rm $id
