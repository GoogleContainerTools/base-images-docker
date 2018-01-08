# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
Rules to run a command inside a container, and either commit the result
to new container image, or extract specified targets to a directory on
the host machine.
"""

workspace(name = "debian_docker")

# Docker rules.
git_repository(
    name = "io_bazel_rules_docker",
    commit = "8aeab63328a82fdb8e8eb12f677a4e5ce6b183b1",
    remote = "https://github.com/bazelbuild/rules_docker.git",
)

load(
    "@io_bazel_rules_docker//docker:docker.bzl",
    "docker_repositories",
    "docker_pull",
)
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

docker_repositories()

docker_pull(
    name = "debian_base",
    digest = "sha256:987494b558cc0c9c341b5808b6e259ee449cf70c6f7c7adce4fd8f15eef1dea2",
    registry = "gcr.io",
    repository = "google-appengine/debian8",
)

git_repository(
    name = "distroless",
    commit = "bd16e2028cc0dd6acba3de58448c94b3d2ead21a",
    remote = "https://github.com/GoogleCloudPlatform/distroless.git",
)

load(
    "@distroless//package_manager:package_manager.bzl",
    "package_manager_repositories",
    "dpkg_src",
    "dpkg_list",
)

package_manager_repositories()

# The Debian snapshot datetime to use. See http://snapshot.debian.org/ for more information.
DEB_SNAPSHOT = "20180104T060422Z"

dpkg_src(
    name = "debian_jessie",
    arch = "amd64",
    distro = "jessie",
    sha256 = "20720c9367e9454dee3d173e4d3fd85ab5530292f4ec6654feb5a810b6bb37ce",
    snapshot = DEB_SNAPSHOT,
    url = "http://snapshot.debian.org/archive",
)

# These are needed to install debootstrap.
dpkg_list(
    name = "package_bundle",
    packages = [
        "ca-certificates",
        "debootstrap",
        "libffi6",
        "libgmp10",
        "libgnutls-deb0-28",
        "libhogweed2",
        "libicu52",
        "libidn11",
        "libnettle4",
        "libp11-kit0",
        "libpsl0",
        "libtasn1-6",
        "wget",
    ],
    sources = [
        "@debian_jessie//file:Packages.json",
    ],
)

git_repository(
    name = "runtimes_common",
    commit = "f0e627c4fae70c4220636eac0d2cedb83391e930",
    remote = "https://github.com/GoogleCloudPlatform/runtimes-common.git",
)

git_repository(
    name = "io_bazel_rules_go",
    remote = "https://github.com/bazelbuild/rules_go.git",
    tag = "0.5.5",
)

load(
    "@io_bazel_rules_go//go:def.bzl",
    "go_repositories",
)

go_repositories()

UBUNTU_MAP = {
    "16_0_4": {
        "sha256": "51a8c466269bdebf232cac689aafad8feacd64804b13318c01096097a186d051",
        "url": "https://storage.googleapis.com/ubuntu_tar/20171028/ubuntu-xenial-core-cloudimg-amd64-root.tar.gz",
    },
}

[http_file(
    name = "ubuntu_%s_tar_download" % version,
    sha256 = map["sha256"],
    url = map["url"],
) for version, map in UBUNTU_MAP.items()]
