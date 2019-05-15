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

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load(":revisions.bzl", "DEBIAN9_TAR")

def deps():
    """Download dependencies required to use this layer."""
    excludes = native.existing_rules().keys()

    # Base Ubuntu1604 tarball.
    if "debian9_tar" not in excludes:
        http_file(
            name = "debian9_tar",
            downloaded_file_path = DEBIAN9_TAR.revision + "_rootfs.tar.gz",
            sha256 = DEBIAN9_TAR.sha256,
            urls = [
                "https://storage.googleapis.com/container-deps/debian9/tar/" + DEBIAN9_TAR.revision + "_rootfs.tar.gz",
            ],
        )
