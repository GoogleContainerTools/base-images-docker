#!/bin/bash
echo "Checking gofmt..."
files=$(gofmt -l -s ./tests)
if [[ $files ]]; then
    echo "Gofmt errors in files: $files"
    exit 1
fi
