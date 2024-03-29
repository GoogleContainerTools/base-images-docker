# Copyright 2017 Google Inc. All rights reserved.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load("@io_bazel_rules_docker//container:container.bzl", "container_image")
load("@io_bazel_rules_docker//contrib:repro_test.bzl", "container_repro_test")
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")
load(
    "@io_bazel_rules_docker//contrib/automatic_container_release:configs_test.bzl",
    "configs_test",
)
load("@io_bazel_rules_docker//docker/security:security_check.bzl", "security_check")
load("@io_bazel_rules_docker//docker/util:run.bzl", "container_run_and_extract")

licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])

VERSION = "8"

# Used by File Update Service only.
pkg_tar(
    name = "chroot_tar",
    srcs = [
        ":chroot.sh",
    ],
    package_dir = "/target/",
    strip_prefix = ".",
    tags = ["manual"],
)

# Used by File Update Service only.
container_image(
    name = "builder",
    base = "@centos_base//image",
    files = [
        ":build.sh",
        "@centos8_latest//file",
    ],
    tars = [
        ":chroot_tar",
    ],
)

# Used by File Update Service only.
container_run_and_extract(
    name = "centos_layer",
    commands = ["/build.sh " + VERSION],
    docker_run_flags = ["--privileged"],
    extract_file = "/layer.tar",
    image = ":builder.tar",
)

container_image(
    name = "image",
    cmd = ["/bin/bash"],
    env = {
        "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    },
    tars = [
        "@centos8_tar//file",
    ],
)

# Run the security check script to generate a metadata YAML file indicating
# whether the centos 8 has critical security vulnerability fixes.
security_check(
    name = "metadata",
    image = "gcr.io/gcp-runtimes/centos8:latest",
)

container_test(
    name = "image-test",
    configs = [":test.yaml"],
    image = ":image",
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
