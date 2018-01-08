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

load(
    "//util:run.bzl",
    "container_run_and_commit",
    "container_run_and_extract",
)
load(
    "@bazel_tools//tools/build_rules:test_rules.bzl",
    "rule_test",
    "file_test",
)
load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")

container_run_and_extract(
    name = "test_container_extract",
    commands = [
        "touch /foo.txt",
        "echo 'test' > /foo.txt",
    ],
    extract_file = "/foo.txt",
    image = "@debian_base//image",
)

rule_test(
    name = "test_container_extract_rule",
    generates = [
        "foo.txt",
    ],
    rule = "test_container_extract",
)

file_test(
    name = "test_extracted_file",
    file = ":foo.txt",
    regexp = "test",
)

container_run_and_commit(
    name = "test_container_commit",
    commands = ["touch /foo.txt"],
    image = "@debian_base//image",
)

rule_test(
    name = "test_container_commit_rule",
    generates = [
        "test_container_commit_commit.tar",
    ],
    rule = "test_container_commit",
)

docker_build(
    name = "test_container_commit_image",
    base = ":test_container_commit",
)

container_test(
    name = "test_container_commit_metadata",
    configs = [":container_commit.yaml"],
    image = ":test_container_commit_image",
)
