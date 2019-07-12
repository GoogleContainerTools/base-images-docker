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
    "@io_bazel_rules_docker//docker/util:run.bzl",
    _commit = "commit",
    _container_run_and_commit = "container_run_and_commit",
    _container_run_and_extract = "container_run_and_extract",
    _extract = "extract",
)

# Redirects all defs to implementation which has been refactored to
# @io_bazel_rules_docker//docker/util:run.bzl

commit = _commit
container_run_and_extract = _container_run_and_extract
container_run_and_commit = _container_run_and_commit
extract = _extract
