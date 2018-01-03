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

""" Rules that create an output script to install packages via apt-get."""

CACHE_DIR = "/tmp/install"

ARCHIVE_DIR = "."

load(
    "@io_bazel_rules_docker//skylib:filetype.bzl",
    tar_filetype = "tar",
)

def _generate_download_commands(ctx):
    return """#!/bin/bash
set -ex
# Fetch Index
apt-get update -y
# Make partial dir
mkdir -p {cache}/{archive}/partial
# Install command
apt-get install --no-install-recommends -y -q -o Dir::Cache="{cache}" -o Dir::Cache::archives="{archive}" {packages} --download-only
# Tar command to only include all the *.deb files and ignore other directories placed in the cache dir.
tar -cpf {output}.tar --directory {cache}/{archive} `cd {cache}/{archive} && ls *.deb`""".format(
    output=ctx.attr.name,
    cache=CACHE_DIR,
    archive=ARCHIVE_DIR,
    packages=' '.join(ctx.attr.packages))

def _impl(ctx):
    download_commands = _generate_download_commands(ctx)

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = download_commands,
    )

    return struct(
        files = depset([ctx.outputs.executable]),
    )

generate_apt_get = rule(
    attrs = {
        "packages": attr.string_list(
            doc = "list of packages to download",
        ),
    },
    executable = True,
    implementation = _impl,
)

"""Fetches and Installs packages via apt-get or bundled debs.

This rule fetches and installs packages via apt-get.

Args:
  packages: List of packages to fetch and install.
"""
