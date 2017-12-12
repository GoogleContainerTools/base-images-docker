#!/bin/bash

set -ex

%{load_statement}

id=$(docker run -d %{flags} %{image} %{commands})

docker wait $id
docker cp $id:%{extract_file} %{output}
docker rm $id
