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
load(":revisions.bzl", "CENTOS7_TAR")

def deps():
    """Download dependencies required to use this layer."""
    excludes = native.existing_rules().keys()

    # Centos release layer tar.
    if "centos7_tar" not in excludes:
        http_file(
            name = "centos7_tar",
            downloaded_file_path = CENTOS7_TAR.revision + "_layer.tar",
            sha256 = CENTOS7_TAR.sha256,
            urls = [
                "https://storage.googleapis.com/container-deps/centos7/tar/" + CENTOS7_TAR.revision + "_layer.tar",
            ],
        )
