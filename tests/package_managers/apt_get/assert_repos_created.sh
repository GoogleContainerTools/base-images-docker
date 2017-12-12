#!/bin/bash

set -ex
BASEDIR=$(dirname "$0")

EXIT_CODE=0

for i in $(seq 0 1); do
    if tar -tvf "$BASEDIR/test_repos.tar" | grep "/etc/apt/sources.list.d/test_repos_$i.list"; then
        echo "sources.list $i found"
    else
        echo "sources.list $i not found."
        EXIT_CODE=1
    fi
done

exit "$EXIT_CODE"
