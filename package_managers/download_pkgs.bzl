#Copyright 2017 Google Inc. All rights reserved.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Rule for downloading apt packages and tar them in a .tar file."""

load(
    "@io_bazel_rules_docker//docker/package_managers:download_pkgs.bzl",
    _download = "download",
    _download_pkgs = "download_pkgs",
)

# Redirects all defs to implementation which has been refactored to
# @io_bazel_rules_docker//docker/package_managers:download_pkgs.bzl

download = _download
download_pkgs = _download_pkgs
