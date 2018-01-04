#!/bin/bash

set -ex
# Build new BUILD file with download_pkgs target
cat > tests/package_managers/BUILD.bazel <<- EOM
load("//package_managers:download_pkgs.bzl", "download_pkgs")

download_pkgs(
    name = "test_complex_download_pkgs",
    image_tar = "//ubuntu:ubuntu_16_0_4_vanilla",
    packages = [
        "curl",
        "netbase",
        "ca-certificates",
    ],
)
EOM

# Run download_pkgs and grab the resulting installables tar file
rm -f test_download_complex_pkgs.tar
bazel run //tests/package_managers:test_complex_download_pkgs
cp  bazel-bin/tests/package_managers/test_complex_download_pkgs.runfiles/debian_docker/tests/package_managers/test_complex_download_pkgs.tar tests/package_managers

# Add install_pkgs target to generated BUILD file
cat >> tests/package_managers/BUILD.bazel <<- EOM
load("//package_managers:install_pkgs.bzl", "install_pkgs")

install_pkgs(
    name = "test_complex_install_pkgs",
    image_tar = "//ubuntu:ubuntu_16_0_4_vanilla.tar",
    output_image_name = "test_complex_install_pkgs",
    installables_tar = ":test_complex_download_pkgs.tar",
)
EOM

# Run install_pkgs and grab the build docker image tar
rm -f tests/package_managers/test_complex_install_pkgs.tar
bazel build //tests/package_managers:test_complex_install_pkgs
cp bazel-bin/tests/package_managers/test_complex_install_pkgs.tar tests/package_managers

# Generate a Dockerfile with the same apt packages and build the docker image
bazel build //ubuntu:ubuntu_16_0_4_vanilla
cat > tests/package_managers/Dockerfile.test <<- EOM
FROM bazel/ubuntu:ubuntu_16_0_4_vanilla

RUN apt-get update && \
  apt-get install --no-install-recommends -y curl netbase ca-certificates
EOM

cid=$(docker build -q - < tests/package_managers/Dockerfile.test)

# Compare it with the tar file built with install_pkgs using container diff
# TODO(selgamal): actually parse out container-diff output once it's fixed
container-diff diff tests/package_managers/test_complex_install_pkgs.tar daemon://"$cid" -j

rm tests/package_managers/BUILD.bazel
