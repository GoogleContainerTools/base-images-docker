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

""" Rules that create additional apt-get repo files."""

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load("//util:run.bzl", "container_run_and_commit")
load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")

def _impl(ctx):
    ctx.actions.write(ctx.outputs.out, content="%s\n" % ctx.attr.repo)

_generate_additional_repo = rule(
    attrs = {
        "repo": attr.string(doc = "Additional repo to add, in sources.list format"),
    },
    executable = False,
    outputs = {
        "out": "%{name}.list",
    },
    implementation = _impl,
)

def generate_additional_repos(name, repos):
    all_repo_files=[]
    for i, repo in enumerate(repos):
        repo_name = "%s_%s" % (name, i)
        all_repo_files.append(repo_name)
        _generate_additional_repo(
            name=repo_name,
            repo=repo
        )
    pkg_tar(
        name=name,
        srcs=all_repo_files,
        package_dir="/etc/apt/sources.list.d/"
    )
"""Generates /etc/apt/sources.list.d/ files with the specified repos.

Args:
  repos: List of repos to add in sources.list format.
"""

def add_gpg_key_from_url(name, image, gpg_url):
    intermediate = "%s.intermediate" % name
    container_run_and_commit(
        name=intermediate,
        image=image,
        commands=["curl {gpg_url} | apt-key add -".format(gpg_url=gpg_url)],
    )
    # Export as an actual docker_image rule for compatibility.
    docker_build(
        name=name,
        base=intermediate,
    )
