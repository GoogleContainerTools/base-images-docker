# Copyright 2017 The Bazel Authors. All rights reserved.
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
    "@io_bazel_rules_docker//container:bundle.bzl",
    "container_bundle",
)

def _extract_impl(ctx):
    # Since we're always bundling/renaming the image in the macro, this is valid.
    load_statement = 'docker load -i %s' % ctx.file.image_tar.path

    script = ctx.new_file(ctx.label.name + ".build")

    # Generate a shell script to execute the run statement
    ctx.actions.expand_template(
        template=ctx.file._extract_tpl,
        output=script,
        substitutions={
          "%{load_statement}": load_statement,
          "%{image}": ctx.attr.image_name,
          "%{commands}": _process_commands(ctx.attr.commands),
          "%{extract_file}": ctx.attr.extract_file,
          "%{output}": ctx.outputs.out.path,
        },
        is_executable=True,
    )

    runfiles = [ctx.file.image_tar] + \
                ctx.attr.image_tar.files.to_list() + \
                ctx.attr.image_tar.data_runfiles.files.to_list()

    ctx.actions.run(
        outputs=[ctx.outputs.out],
        inputs=runfiles,
        executable=script,
    )

    return struct()

def _commit_impl(ctx):
    # Since we're always bundling/renaming the image in the macro, this is valid.
    load_statement = 'docker load -i %s' % ctx.file.image_tar.path

    script = ctx.new_file(ctx.label.name + ".build")

    # Generate a shell script to execute the run statement
    ctx.actions.expand_template(
        template=ctx.file._run_tpl,
        output=script,
        substitutions={
          "%{output_image}": 'bazel/%s:%s' % (ctx.label.package or 'default',
                                              ctx.attr.name),
          "%{load_statement}": load_statement,
          "%{image}": ctx.attr.image_name,
          "%{commands}": _process_commands(ctx.attr.commands),
          "%{output_tar}": ctx.outputs.out.path,
        },
        is_executable=True,
    )

    runfiles = [ctx.file.image_tar] + \
                ctx.attr.image_tar.files.to_list() + \
                ctx.attr.image_tar.data_runfiles.files.to_list()

    ctx.actions.run(
        outputs=[ctx.outputs.out],
        inputs=runfiles,
        executable=script,
    )

    return struct()

_run_and_commit = rule(
    attrs = {
        "image_tar": attr.label(
            allow_files = True,
            mandatory = True,
            single_file = True,
            cfg = "target",
        ),
        "image_name": attr.string(
            doc = "name of image to run commands on",
            mandatory = True,
        ),
        "commands": attr.string_list(
            doc = "commands to run",
            mandatory = True,
            non_empty = True,
        ),
        "_run_tpl": attr.label(
            default = Label("//util:commit.sh.tpl"),
            allow_files = True,
            single_file = True,
        ),
    },
    executable = False,
    outputs = {
        "out": "%{name}_commit.tar",
    },
    implementation = _commit_impl,
)

"""Runs commands in a container and commits the container to a new image.

This rule runs a set of commands in a given image, waits for the commands
to finish, and then commits the container to a new image.


Args:
    image_name: Name of the image to run commands on.
    image_tar: Tarball of image to run commands on.
    commands: A list of commands to run (sequentially) in the container.
    _run_tpl: Template for generated script to run docker commands.
"""

_run_and_extract = rule(
    attrs = {
        "image_tar": attr.label(
            executable = True,
            allow_files = True,
            mandatory = True,
            single_file = True,
            cfg = "target",
        ),
        "image_name": attr.string(
            doc = "name of image to run commands on",
            mandatory = True,
        ),
        "commands": attr.string_list(
            doc = "commands to run",
            mandatory = True,
            non_empty = True,
        ),
        "extract_file": attr.string(
            doc = "path to file to extract from container",
            mandatory = True,
        ),
        "_extract_tpl": attr.label(
            default = Label("//util:extract.sh.tpl"),
            allow_files = True,
            single_file = True,
        ),
        "output_file": attr.string(
            mandatory = True,
        ),
    },
    executable = False,
    outputs = {
        "out": "%{output_file}",
    },
    implementation = _extract_impl,
)

"""Runs commands in a container and extracts a target file from the container.

This rule runs a set of commands in a given image, waits for the commands
to finish, and then extracts a given file from the container.

Args:
    image_name: Name of the image to run commands on
    image_tar: Tarball of image to run commands on
    commands: A list of commands to run (sequentially) in the container.
    extract_file: The file to extract from the container.
    output_file: Path to output file extracted from container.
    _extract_tpl: Template for generated script to run docker commands.
"""

def container_run_and_commit(name, image, commands):
    """Macro to wrap the run_and_commit implementation.

    This rule runs a set of commands in a given image, waits for the commands
    to finish, and then commits the container to a new image.

    Args:
        name: A unique name for this rule.
        image: The image to run the commands in.
        commands: A list of commands to run (sequentially) in the container.
    """
    image_tar, intermediate_image = _rename_image(image, name)

    _run_and_commit(
        name = name,
        image_name = intermediate_image,
        image_tar = image_tar + ".tar",
        commands = commands,
    )

def container_run_and_extract(name, image, commands, extract_file):
    """Macro to wrap the run_and_extract implementation.

    This rule runs a set of commands in a given image, waits for the commands
    to finish, and then extracts a given file from the container.

    Args:
        name: A unique name for this rule.
        image: The image to run the commands in.
        commands: A list of commands to run (sequentially) in the container.
        extract_file: The file to extract from the container.
    """
    image_tar, intermediate_image = _rename_image(image, name)

    _run_and_extract(
        name = name,
        image_name = intermediate_image,
        image_tar = image_tar + ".tar",
        commands = commands,
        extract_file = extract_file,
        output_file = extract_file.lstrip("/"),
    )

def _process_commands(command_list):
    # Use the $ to allow escape characters in string
    return 'sh -c $\"{0}\"'.format(" && ".join(command_list))

def _rename_image(image, name):
    # TODO(nkubala): this should live in rules_docker

    """A macro to predictably rename the image under test."""
    intermediate_image_name = "%s:intermediate" % image.replace(':', '').replace('@', '').replace('/', '')
    image_tar_name = "intermediate_bundle_%s" % name

    # Give the image a predictable name when loaded
    container_bundle(
        name = image_tar_name,
        images = {
            intermediate_image_name: image,
        }
    )
    return image_tar_name, intermediate_image_name
