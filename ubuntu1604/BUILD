# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("@base_images_docker//package_managers:security_check.bzl", "security_check")
load(
    "@bazel_toolchains//rules/container:docker_toolchains.bzl",
    "toolchain_container",
)
load("@bazel_toolchains//rules/container:metadata_merge.bzl", "metadata_merge")
load("@bazel_toolchains//rules/container:packages_metadata.bzl", "packages_metadata")
load("@io_bazel_rules_docker//container:container.bzl", "container_image")
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")
load("@io_bazel_rules_docker//docker/package_managers:download_pkgs.bzl", "download_pkgs")

licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])

UBUNTU_ENV = {
    "DEBIAN_FRONTEND": "noninteractive",
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

container_image(
    name = "ubuntu1604_vanilla",
    env = UBUNTU_ENV,
    tars = ["@ubuntu1604_tar//file"],
)

download_pkgs(
    name = "debs",
    image_tar = ":ubuntu1604_vanilla.tar",
    packages = [
        "ca-certificates",
        "curl",
        "libc-bin",
        "netbase",
    ],
)

# Generate the container.
toolchain_container(
    name = "image",
    base = ":ubuntu1604_vanilla.tar",
    cmd = [
        "/bin/sh",
        "-c",
    ],
    env = UBUNTU_ENV,
    installables_tar = "@ubuntu1604_debs//file",
)

# Run the security check script to generate a metadata YAML file indicating
# whether the ubuntu 16.04 has critical security vulnerability fixes.
security_check(
    name = "security_metadata",
    image = "gcr.io/asci-toolchain/ubuntu1604-xingao-test:latest",
)

# Transform the packages metadata csv produced by download_pkgs into a YAML
# file.
packages_metadata(
    name = "debs_metadata",
    metadata_csv = ":debs_metadata.csv",
)

# Merge the packages metadata & vulnerability YAML into a single merged YAML
# file.
metadata_merge(
    name = "metadata",
    srcs = [
        ":debs_metadata.yaml",
        ":security_metadata.yaml",
    ],
)

container_test(
    name = "image-test",
    configs = [
        ":tests.yaml",
    ],
    image = ":image",
    verbose = True,
)
