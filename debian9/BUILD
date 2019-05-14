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
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")
load(
    "@package_bundle//file:packages.bzl",
    builder_packages = "packages",
)
load("//:debootstrap.bzl", "debootstrap_image")
load("//:revisions.bzl", "DEB_SNAPSHOT")

licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])

container_image(
    name = "builder",
    base = "@debian_base//image",
    debs = builder_packages.values(),
    files = [":mkimage.sh"],
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

debootstrap_image(
    name = "image",
    builder_image = ":builder.tar",
    distro = "stretch",
    env = DEBIAN_ENV,
    overlay_tar = ":overlay.tar",
    snapshot = DEB_SNAPSHOT.revision,
)

container_test(
    name = "image-test",
    configs = [":test.yaml"],
    image = ":image",
)
