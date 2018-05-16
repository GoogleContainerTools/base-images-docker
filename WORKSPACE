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

workspace(name = "base_images_docker")

# Docker rules.
git_repository(
    name = "io_bazel_rules_docker",
    commit = "1144f83122750fe4aca139bd0f205d99c9bd94c1",
    remote = "https://github.com/bazelbuild/rules_docker.git",
)

load(
    "@io_bazel_rules_docker//docker:docker.bzl",
    "docker_pull",
    "docker_repositories",
)

git_repository(
    name = "bazel_skylib",
    remote = "https://github.com/bazelbuild/bazel-skylib.git",
    tag = "0.2.0",
)

git_repository(
    name = "structure_test",
    commit = "fa9226712ab31e808b240a616056e2abc2fdf40a",
    remote = "https://github.com/GoogleCloudPlatform/container-structure-test.git",
)

git_repository(
    name = "subpar",
    commit = "7e12cc130eb8f09c8cb02c3585a91a4043753c56",
    remote = "https://github.com/google/subpar",
)

docker_repositories()

docker_pull(
    name = "debian_base",
    digest = "sha256:987494b558cc0c9c341b5808b6e259ee449cf70c6f7c7adce4fd8f15eef1dea2",
    registry = "gcr.io",
    repository = "google-appengine/debian8",
)

git_repository(
    name = "distroless",
    commit = "813d1ddef217f3871e4cb0a73da100aeddc638ee",
    remote = "https://github.com/GoogleContainerTools/distroless.git",
)

load(
    "@distroless//package_manager:package_manager.bzl",
    "dpkg_list",
    "dpkg_src",
    "package_manager_repositories",
)

package_manager_repositories()

# The Debian snapshot datetime to use. See http://snapshot.debian.org/ for more information.
DEB_SNAPSHOT = "20180426T224735Z"

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

http_archive(
    name = "io_bazel_rules_go",
    sha256 = "f70c35a8c779bb92f7521ecb5a1c6604e9c3edd431e50b6376d7497abc8ad3c1",
    url = "https://github.com/bazelbuild/rules_go/releases/download/0.11.0/rules_go-0.11.0.tar.gz",
)

load("@io_bazel_rules_go//go:def.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains()

UBUNTU_MAP = {
    "16_0_4": {
        "sha256": "af1117726fe4c17692bf9c60dc4ff7cadfe8545affb91e71f1ce90a3143f0b03",
        "url": "https://storage.googleapis.com/ubuntu_tar/20180516/ubuntu-xenial-core-cloudimg-amd64-root.tar.gz",
    },
    "18_0_4": {
        "sha256": "9256337473faab9bc070609c2b7bd977735aa7cad117feb93f545346846c4cb9",
        "url": "https://storage.googleapis.com/ubuntu_tar/20180516/ubuntu-bionic-core-cloudimg-amd64-root.tar.gz",
    },
}

[http_file(
    name = "ubuntu_%s_tar_download" % version,
    sha256 = map["sha256"],
    url = map["url"],
) for version, map in UBUNTU_MAP.items()]

http_file(
    name = "bazel_gpg",
    sha256 = "e0e806160454a3e5e308188439525896bf9881f1f2f0b887192428f517da4131",
    url = "https://bazel.build/bazel-release.pub.gpg",
)

http_file(
    name = "launchpad_openjdk_gpg",
    sha256 = "54b6274820df34a936ccc6f5cb725a9b7bb46075db7faf0ef7e2d86452fa09fd",
    url = "http://keyserver.ubuntu.com/pks/lookup?op=get&fingerprint=on&search=0xEB9B1D8886F44E2A",
)
