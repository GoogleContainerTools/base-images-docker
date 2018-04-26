#!/bin/bash
set -ex

echo "Checking gofmt..."
files=$(gofmt -l -s ./tests)
if [[ $files ]]; then
    echo "Gofmt errors in files: $files"
    exit 1
fi

echo "Checking buildifer..."
# shellcheck disable=SC2046
files=$(buildifier -mode=check $(find . -not -path "./vendor/*" -name 'BUILD' -type f))
if [[ $files ]]; then
    echo "$files"
    echo "Run 'buildifier -mode fix \$(find . -name BUILD -type f)' to fix formatting"
    exit 1
fi


#echo "Checking shellcheck..."
#find . -name "*.sh" | grep -v "third_party/" | xargs shellcheck
