#!/bin/bash

set -ex

%{load_statement}

id=$(docker run -d --privileged %{flags} %{image} %{command})

docker commit $id %{output_image}
