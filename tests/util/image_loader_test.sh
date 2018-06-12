#!/bin/bash

image_loader=$1

set -exu

test `./$image_loader -o 'Loaded image ID: sha256:593fa78799748eecb65019e8cc54b1f8dfa29fb4fe3b28bc597e3972a7b15ce3'` = "593fa78799748eecb65019e8cc54b1f8dfa29fb4fe3b28bc597e3972a7b15ce3"

test `./$image_loader -o 'Loaded image: ubuntu:latest'` = "ubuntu:latest"

exit 0
