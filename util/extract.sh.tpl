#!/bin/bash

set -ex

%{load_statement}

id=$(docker run -d --privileged %{flags} %{image} %{command})

docker wait $id
docker cp $id:%{extract_file} %{target}
docker rm $id
