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
    commit = "7401cb256222615c497c0dee5a4de5724a4f4cc7",
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
    commit = "61f1d2f394e1fa1cd62f703cd51a8300e225da5a",
    remote = "https://github.com/GoogleCloudPlatform/container-structure-test.git",
)

git_repository(
    name = "runtimes_common",
    commit = "9828ee5659320cebbfd8d34707c36648ca087888",
    remote = "https://github.com/GoogleCloudPlatform/runtimes-common.git",
)

new_http_archive(
    name = "docker_credential_gcr",
    build_file_content = """package(default_visibility = ["//visibility:public"])
exports_files(["docker-credential-gcr"])""",
    sha256 = "3f02de988d69dc9c8d242b02cc10d4beb6bab151e31d63cb6af09dd604f75fce",
    type = "tar.gz",
    url = "https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v1.4.3/docker-credential-gcr_linux_amd64-1.4.3.tar.gz",
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
DEB_SNAPSHOT = "20180625T203737Z"

dpkg_src(
    name = "debian_jessie",
    arch = "amd64",
    distro = "jessie",
    sha256 = "7240a1c6ce11c3658d001261e77797818e610f7da6c2fb1f98a24fdbf4e8d84c",
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
        "sha256": "7faa16873c39a5b7485ac1e38dbcdbf1066005b8e975d3abb7a9375e32351aa3",
        "url": "https://storage.googleapis.com/ubuntu_tar/20180620/ubuntu-xenial-core-cloudimg-amd64-root.tar.gz",
    },
    "18_0_4": {
        "sha256": "19cb81b929fa41210f4e76f8f27141482518aad65876540aef6d714837248489",
        "url": "https://storage.googleapis.com/ubuntu_tar/20180625/ubuntu-bionic-core-cloudimg-amd64-root.tar.gz",
    },
}

[http_file(
    name = "ubuntu_%s_tar_download" % version,
    sha256 = map["sha256"],
    url = map["url"],
) for version, map in UBUNTU_MAP.items()]

http_file(
    name = "bazel_gpg",
    sha256 = "30af2ca7abfb65987cd61802ca6e352aadc6129dfb5bfc9c81f16617bc3a4416",
    url = "https://bazel.build/bazel-release.pub.gpg",
)

http_file(
    name = "launchpad_openjdk_gpg",
    sha256 = "54b6274820df34a936ccc6f5cb725a9b7bb46075db7faf0ef7e2d86452fa09fd",
    url = "http://keyserver.ubuntu.com/pks/lookup?op=get&fingerprint=on&search=0xEB9B1D8886F44E2A",
)
