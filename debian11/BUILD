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
load(
    "@io_bazel_rules_docker//docker/toolchain_container:toolchain_container.bzl",
    "toolchain_container",
)

licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])

toolchain_container(
    name = "builder",
    base = "@debian_base//image",
    files = [":mkimage.sh"],
    packages = [
        "debootstrap",
    ],
)

# Generate a debian rootfs using debootstrap. See `mkimage.sh` for more details.
# Do not use this directly in the container_image target below. Use the archived
# version to ensure container reproducibility.
container_run_and_extract(
    name = "rootfs",
    commands = [
        " ".join([
            "/mkimage.sh",
            "minbase",
            "bullseye",
        ]),
    ],
    docker_run_flags = ["--privileged"],
    extract_file = "/workspace/rootfs.tar.gz",
    image = ":builder.tar",
)

# The overlay directory contains files that should be overlaid into the rootfs at /.
pkg_tar(
    name = "overlay",
    srcs = glob(["overlay/**/*"]),
    package_dir = "/",
    strip_prefix = "overlay/",
)

DEBIAN_ENV = {
    "DEBIAN_FRONTEND": "noninteractive",
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    "PORT": "8080",
}

container_image(
    name = "image",
    cmd = "/bin/bash",
    env = DEBIAN_ENV,
    tars = [
        # The overlay tar has to come first to actually overwrite existing files.
        ":overlay.tar",
        "@debian11_tar//file",
    ],
)

# Run the security check script to generate a metadata YAML file indicating
# whether debian11 has critical security vulnerability fixes.
security_check(
    name = "metadata",
    image = "gcr.io/google-appengine/debian11:latest",
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
