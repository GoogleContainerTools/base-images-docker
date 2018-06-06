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
    "@io_bazel_rules_docker//container:bundle.bzl",
    "container_bundle",
)

def _extract_impl(ctx, name = "", image = None, commands = None, extract_file = "", output_file = ""):
    """Implementation for the container_run_and_extract rule.

    This rule runs a set of commands in a given image, waits for the commands
    to finish, and then extracts a given file from the container to the
    bazel-out directory.

    Args:
        ctx: The bazel rule context
        name: String, overrides ctx.label.name
        image: File, overrides ctx.file.image_tar
        commands: String list, overrides ctx.attr.commands
        extract_file: File, overrides ctx.outputs.out
    """

    name = name or ctx.label.name
    image = image or ctx.file.image
    commands = commands or ctx.attr.commands
    extract_file = extract_file or ctx.attr.extract_file
    output_file = output_file or ctx.outputs.out
    script = ctx.new_file(name + ".build")

    # Generate a shell script to execute the run statement
    ctx.actions.expand_template(
        template = ctx.file._extract_tpl,
        output = script,
        substitutions = {
            "%{image_tar}": image.path,
            "%{commands}": _process_commands(commands),
            "%{extract_file}": extract_file,
            "%{output}": output_file.path,
            "%{image_loader_path}": ctx.file._image_loader.path,
        },
        is_executable=True,
    )

    ctx.actions.run(
        outputs = [output_file],
        inputs = [image, ctx.file._image_loader],
        executable = script,
    )

    return struct()

_extract_attrs = {
    "image": attr.label(
        executable = True,
        allow_files = True,
        mandatory = True,
        single_file = True,
        cfg = "target",
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
    "_image_loader": attr.label(
      default = "//util:image_loader.sh",
      allow_files = True,
      single_file = True,
    ),
}

_extract_outputs = {
    "out": "%{name}%{extract_file}",
}

# Export container_run_and_extract rule for other bazel rules to depend on.
extract = struct(
    attrs = _extract_attrs,
    outputs = _extract_outputs,
    implementation = _extract_impl,
)


'''
This rule runs a set of commands in a given image, waits for the commands
    to finish, and then extracts a given file from the container to the
    bazel-out directory.

    name: A unique name for this rule.
    image: The image to run the commands in.
    commands: A list of commands to run (sequentially) in the container.
    extract_file: The file to extract from the container.
'''
container_run_and_extract = rule(
    attrs = _extract_attrs,
    outputs = _extract_outputs,
    implementation = _extract_impl,
)

def _commit_impl(ctx):
    """Implementation for the container_run_and_commit rule.

    This rule runs a set of commands in a given image, waits for the commands
    to finish, and then commits the container to a new image.

    Args:
        ctx: The bazel rule context
    """
    script = ctx.new_file(ctx.label.name + ".build")

    # Generate a shell script to execute the run statement
    ctx.actions.expand_template(
        template=ctx.file._run_tpl,
        output=script,
        substitutions={
          "%{util_script}": ctx.file._image_utils.path,
          "%{output_image}": 'bazel/%s:%s' % (ctx.label.package or 'default',
                                              ctx.attr.name),
          "%{image_tar}": ctx.file.image.path,
          "%{commands}": _process_commands(ctx.attr.commands),
          "%{output_tar}": ctx.outputs.out.path,
          "%{image_loader_path}": ctx.file._image_loader.path,
        },
        is_executable=True,
    )

    runfiles = [ctx.file.image, ctx.file._image_utils, ctx.file._image_loader] + \
                ctx.attr.image.files.to_list() + \
                ctx.attr.image.data_runfiles.files.to_list()

    ctx.actions.run(
        outputs=[ctx.outputs.out],
        inputs=runfiles,
        executable=script,
    )

    return struct()

"""Runs commands in a container and commits the container to a new image.

This rule runs a set of commands in a given image, waits for the commands
to finish, and then commits the container to a new image.


Args:
    image: Tarball of image to run commands on.
    commands: A list of commands to run (sequentially) in the container.
    _run_tpl: Template for generated script to run docker commands.
    _image_loader: A script to load a tar ball into docker while also remembering its name/id
"""
container_run_and_commit = rule(
    attrs = {
        "image": attr.label(
            allow_files = True,
            mandatory = True,
            single_file = True,
            cfg = "target",
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
        "_image_utils": attr.label(
            default = "//util:image_util.sh",
            allow_files = True,
            single_file = True,
        ),
        "_image_loader": attr.label(
          default = "//util:image_loader.sh",
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
