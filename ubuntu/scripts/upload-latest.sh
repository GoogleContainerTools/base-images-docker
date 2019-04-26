#!/bin/bash
#
# Safely copy the latest image for an Ubuntu version to GCS
#
# Usage:
#   upload_latest.sh 16_0_4
#
# Debugging Usage:
#   bash -x upload_latest.sh 16_0_4
#
set -eu -o pipefail

readonly VERSION=$1
readonly GCS_BUCKET="ubuntu_tar"

case $VERSION in
  16_0_4)
    readonly release="xenial"
    ;;
  18_0_4)
    readonly release="bionic"
    ;;
  *)
    echo "Unknown version: $VERSION"
    exit 1
    ;;
esac

readonly TMP_DIR=/tmp/${release}/$(date '+%Y-%m-%d')
mkdir -p "${TMP_DIR}"
cd "${TMP_DIR}"
echo "Temp directory: ${TMP_DIR}"


readonly base_url="https://partner-images.canonical.com/core/${release}/current"
curl -OR "${base_url}/SHA256SUMS"
readonly archive="ubuntu-${release}-core-cloudimg-amd64-root.tar.gz"
curl -OR "${base_url}/${archive}"

sha256sum --ignore-missing -c SHA256SUMS || exit 9
checksum=$(sha256sum ${archive} | awk '{ print $1 }')

# NOTE: Build dates are in GMT
readonly build=$(TZ=Z stat -c '%y' "${archive}" | cut -d" " -f1 | sed s/-//g)
readonly dest="${GCS_BUCKET}/${build}/${archive}"

gsutil cp "${archive}" "gs://${dest}"

echo "Copy completed! Here is an updated WORKSPACE entry for you:"
cat <<EOF

    "${VERSION}": {
        "sha256": "${checksum}",
        "url": "https://storage.googleapis.com/${GCS_BUCKET}/${build}/${archive}",
    },
EOF
