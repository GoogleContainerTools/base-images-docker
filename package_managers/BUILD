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

package(default_visibility = ["//visibility:public"])

exports_files(["installer.sh.tpl"])

load("//package_managers:download_pkgs.bzl", "download_pkgs")
load("//package_managers:install_pkgs.bzl", "install_pkgs")

download_pkgs(
    name = "apt_key_pkgs",
    image_tar = "//debian/reproducible:debian9.tar",
    packages = ["gnupg"],
)

install_pkgs(
    name = "apt_key_image",
    image_tar = "//debian/reproducible:debian9.tar",
    installables_tar = "//package_managers:apt_key_pkgs.tar",
    output_image_name = "gcr.io/gcp-runtimes/apt_key:latest",
)
