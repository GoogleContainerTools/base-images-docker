#!/bin/bash

set -ex

# Load utils
source %{util_script}

%{load_statement}

id=$(docker run -d %{image} %{commands})

reset_cmd %{image} $id %{output_image}

docker save %{output_image} -o %{output_tar}
docker rm $id
