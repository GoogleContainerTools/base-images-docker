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

Both return the image id of the committed container.
"""

load(
    "@io_bazel_rules_docker//container:bundle.bzl",
    "container_bundle",
)


def _extract_impl(ctx):
    # Since we're always bundling/renaming the image in the macro, this is valid.
    load_statement = 'docker load -i %s' % ctx.file.image_tar.short_path

    # Generate a shell script to execute the run statement
    ctx.actions.expand_template(
        template=ctx.file._extract_tpl,
        output=ctx.outputs.executable,
        substitutions={
          "%{load_statement}": load_statement,
          "%{flags}": " ".join(ctx.attr.flags),
          "%{image}": ctx.attr.image_name,
          "%{command}": _process_command(ctx.attr.command),
          "%{extract_file}": ctx.attr.extract_file,
          "%{target}": ctx.attr.target,
        },
        is_executable=True,
    )

    return struct(runfiles=ctx.runfiles(files = [
            ctx.executable.image_tar,
            ctx.file.image_tar] + 
            ctx.attr.image_tar.files.to_list() + 
            ctx.attr.image_tar.data_runfiles.files.to_list()
        ),
    )


def _commit_impl(ctx):
    # Since we're always bundling/renaming the image in the macro, this is valid.
    load_statement = 'docker load -i %s' % ctx.file.image_tar.short_path

    # Generate a shell script to execute the run statement
    ctx.actions.expand_template(
        template=ctx.file._run_tpl,
        output=ctx.outputs.executable,
        substitutions={
          "%{load_statement}": load_statement,
          "%{flags}": " ".join(ctx.attr.flags),
          "%{image}": ctx.attr.image_name,
          "%{original_image}": ctx.attr.original_image,
          "%{command}": _process_command(ctx.attr.command),
        },
        is_executable=True,
    )

    return struct(runfiles=ctx.runfiles(files = [
            ctx.executable.image_tar,
            ctx.file.image_tar] + 
            ctx.attr.image_tar.files.to_list() + 
            ctx.attr.image_tar.data_runfiles.files.to_list()
        ),
    )


_run_and_commit = rule(
    attrs = {
        "flags": attr.string_list(
            doc = "list of flags to pass to run command",
            default = [],
        ),
        "image_tar": attr.label(
            executable = True,
            allow_files = True,
            mandatory = True,
            single_file = True,
            cfg = "target",
        ),
        "original_image": attr.string(
            doc = "name of original image (for computing sha)",
            mandatory = True,
        ),
        "image_name": attr.string(
            doc = "name of image to run commands on",
            mandatory = True,
        ),
        "command": attr.string_list(
            doc = "command to run",
            mandatory = True,
            non_empty = True,
        ),
        "_run_tpl": attr.label(
            default = Label("//util:commit.sh.tpl"),
            allow_files = True,
            single_file = True,
        ),
    },
    executable = True,
    implementation = _commit_impl,
)


_run_and_extract = rule(
    attrs = {
        "flags": attr.string_list(
            doc = "list of flags to pass to run command",
            default = [],
        ),
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
        "command": attr.string_list(
            doc = "command to run",
            mandatory = True,
            non_empty = True,
        ),
        "extract_file": attr.string(
            doc = "path to file to extract from container",
            mandatory = True,
        ),
        "target": attr.string(
            doc = "path to extract file to on host machine",
            default = ".",
        ),
        "_extract_tpl": attr.label(
            default = Label("//util:extract.sh.tpl"),
            allow_files = True,
            single_file = True,
        ),
    },
    executable = True,
    implementation = _extract_impl,
)


def container_run_and_commit(name, image, command, flags=None):
    image_tar, intermediate_image = _rename_image(image, name)

    _run_and_commit(
        name = name,
        original_image = image,
        image_name = intermediate_image,
        image_tar = image_tar + ".tar",
        flags = flags,
        command = command,
    )


def container_run_and_extract(name, image, command, extract_file, target, flags=None):
    image_tar, intermediate_image = _rename_image(image, name)

    _run_and_extract(
        name = name,
        image_name = intermediate_image,
        image_tar = image_tar + ".tar",
        flags = flags,
        command = command,
        extract_file = extract_file,
        target = target,
    )


def _process_command(command_list):
    # Use the $ to allow escape characters in string
    return 'sh -c $\"{0}\"'.format(" && ".join(command_list))


def _rename_image(image, name):
    """A macro to predictably rename the image under test before threading
    it to the container test rule."""
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
