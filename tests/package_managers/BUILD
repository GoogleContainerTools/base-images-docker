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

package(default_visibility = ["//visibility:public"])

load(
    "@bazel_tools//tools/build_rules:test_rules.bzl",
    "rule_test",
)
load("@io_bazel_rules_docker//contrib:compare_ids_test.bzl", "compare_ids_test")
load("//package_managers:bootstrap_image.bzl", "bootstrap_image_macro")

bootstrap_image_macro(
    name = "bootstrap_ubuntu",
    date = "20190301",
    image_tar = "//ubuntu:ubuntu_16_0_4_vanilla.tar",
    output_image_name = "ubuntu",
    packages = [
        "curl",
        "netbase",
    ],
    store_location = "ubuntu/16_0_4/builds",
)

rule_test(
    name = "test_bootstrap_ubuntu",
    generates = [
        "bootstrap_ubuntu-layer.tar",
    ],
    rule = "bootstrap_ubuntu",
)
