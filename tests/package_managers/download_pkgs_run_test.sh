#!/bin/bash

set -ex

BASEDIR=$(dirname "$0")
EXPECTED_TAR="$BASEDIR/test_download_pkgs.tar"
EXIT_CODE=0

if tar -tvf "$EXPECTED_TAR" | grep "netbase"; then
    echo "Netbase found"
else
    echo "Netbase not found"
    EXIT_CODE=1
fi

if tar -tvf "$EXPECTED_TAR" | grep "curl"; then
    echo "curl found"
else
    echo "curl not found"
    EXIT_CODE=1
fi

exit "$EXIT_CODE"
