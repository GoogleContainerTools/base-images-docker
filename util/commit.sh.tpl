#!/bin/bash

set -ex

%{load_statement}

output_tag=$(echo '%{original_image}:%{commands}' | md5sum | cut -d' ' -f1)

id=$(docker run -d --privileged %{flags} %{image} %{command})

docker commit $id run_and_commit:$output_tag
docker save run_and_commit:$output_tag -o %{output_image}
