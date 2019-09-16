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

load("@io_bazel_rules_docker//container:container.bzl", "container_image")
load("@io_bazel_rules_docker//contrib:repro_test.bzl", "container_repro_test")
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")
load(
    "@io_bazel_rules_docker//contrib/automatic_container_release:configs_test.bzl",
    "configs_test",
)
load("@io_bazel_rules_docker//contrib/automatic_container_release:metadata_merge.bzl", "metadata_merge")
load("@io_bazel_rules_docker//contrib/automatic_container_release:packages_metadata.bzl", "packages_metadata")
load("@io_bazel_rules_docker//docker/package_managers:download_pkgs.bzl", "download_pkgs")
load("@io_bazel_rules_docker//docker/security:security_check.bzl", "security_check")
load(
    "@io_bazel_rules_docker//docker/toolchain_container:toolchain_container.bzl",
    "toolchain_container",
)

licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])

UBUNTU_ENV = {
    "DEBIAN_FRONTEND": "noninteractive",
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

container_image(
    name = "ubuntu1804_vanilla",
    env = UBUNTU_ENV,
    tars = ["@ubuntu1804_tar//file"],
)

download_pkgs(
    name = "debs",
    image_tar = ":ubuntu1804_vanilla.tar",
    packages = [
        "ca-certificates",
        "curl",
        "libc-bin",
        "netbase",
    ],
)

# Run the security check script to generate a metadata YAML file indicating
# whether the ubuntu 18.04 has critical security vulnerability fixes.
security_check(
    name = "security_metadata",
    image = "gcr.io/gcp-runtimes/ubuntu_18_0_4:latest",
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

# Generate the container.
toolchain_container(
    name = "image",
    base = ":ubuntu1804_vanilla.tar",
    cmd = [
        "/bin/sh",
        "-c",
    ],
    env = UBUNTU_ENV,
    installables_tar = "@ubuntu1804_debs//file",
    installation_cleanup_commands = "apt-get clean",
)

container_test(
    name = "image-test",
    configs = [
        ":tests.yaml",
    ],
    image = ":image",
    verbose = True,
)

container_repro_test(
    name = "img_repro_test",
    image = ":image",
    workspace_file = "//:WORKSPACE",
)

configs_test(
    name = "configs_test",
    dependency_update_specs = ["deps_spec.yaml"],
    file_update_specs = ["file_updates.yaml"],
)
