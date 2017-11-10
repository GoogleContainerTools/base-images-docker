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

def _impl(ctx):
    shell_file_contents = []
    apt_get_commands = []

    #Shell file commands
    shell_file_contents.append('#!/bin/bash')
    shell_file_contents.append('set -ex')

    #Fetch Index
    apt_get_commands.append('apt-get update -y')
    #Make partial dir
    apt_get_commands.append('mkdir -p {0}/{1}/partial'.format(ctx.attr.cache_dir, ctx.attr.archive_dir))
    install_command = 'apt-get install --no-install-recommends -y -q -o Dir::Cache="{0}" -o Dir::Cache::archives="{1}" {2}'.format(
        ctx.attr.cache_dir,
        ctx.attr.archive_dir,
        ' '.join(ctx.attr.packages))
    if ctx.attr.download_only:
        install_command += ' --download-only'
    #Install command
    apt_get_commands.append(install_command)
    tar_command = "tar -cpf {output}.tar --directory {cache}/{archive} `cd {cache}/{archive} && ls *.deb`".format(
        output=ctx.attr.name,
        cache=ctx.attr.cache_dir,
        archive=ctx.attr.archive_dir,
    )
    apt_get_commands.append(tar_command)
    shell_file_contents.append( ' && '.join(apt_get_commands))
    ctx.file_action(output = ctx.outputs.executable,
                    content = '\n'.join(shell_file_contents),
                    executable = True)

generate_apt_get = rule(
    attrs = {
        "packages": attr.string_list(doc = "list of packages to download"),
        "cache_dir": attr.string(
            default = "/var/cache/apt",
            doc = "apt-get cache directory",
        ),
        "archive_dir": attr.string(
            default = "archives",
            doc = "apt-get archive directory relative to cache dir",
        ),
        "download_only": attr.bool(
            default = False,
            doc = "Set true if you only want to download the package",
        ),
    },
    executable = True,
    implementation = _impl,
)
