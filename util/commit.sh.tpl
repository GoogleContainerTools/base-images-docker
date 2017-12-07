#!/bin/bash

set -ex

%{load_statement}

output_tag=$(echo '%{original_image}:%{command}' | md5)

id=$(docker run -d --privileged %{flags} %{image} %{command})

docker commit $id run_and_commit:$output_tag
