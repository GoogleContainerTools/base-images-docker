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

"""Rule for downloading apt packages and tar them in a .tar file."""

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load("//package_managers/apt_get:apt_get.bzl", "generate_apt_get")
load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")
load("@io_bazel_rules_docker//skylib:filetype.bzl", "container")

def _impl(ctx):
    image_name = ctx.attr.base.label.name.split('.', 1)[0]
    # docker_build rules always generate an image named 'bazel/$package:$name'.
    builder_image_name = "bazel/%s:%s" % (ctx.attr.base.label.package,
                                          image_name)
    # Generate a shell script to run apt_get inside this docker image.
    # TODO(tejaldesai): Replace this by docker_run rule

    build_contents = """\
#!/bin/bash
set -ex
# Execute the loader script.
{loader_script}
command=$(cat {package_manager_script})
# Run the builder image.
cid=$(docker run -d --privileged -w /workspace {image_name} /bin/bash -c "$command")
docker cp $cid:/workspace/installables.tar {output}
# Cleanup
docker rm $cid
 """.format(loader_script=ctx.executable.base.path,
            image_name=builder_image_name,
            package_manager_script=ctx.executable.package_manager_generator.path,
            script_output=ctx.attr.package_manager_generator.label.name,
            output=ctx.outputs.out.path)
    script = ctx.new_file(ctx.label.name + ".build")
    ctx.file_action(
        output=script,
        content=build_contents
    )

    ctx.action(
        outputs=[ctx.outputs.out],
        inputs=ctx.attr.base.files.to_list() +
        ctx.attr.base.data_runfiles.files.to_list() + ctx.attr.base.default_runfiles.files.to_list() +
        ctx.attr.package_manager_generator.files.to_list(),
        executable=script,
    )

download_pkgs = rule(
    attrs = {
        "base": attr.label(
            default = Label("//ubuntu:ubuntu_16_0_4_vanilla"),
            cfg = "target",
            executable = True,
            allow_files = True,
            single_file = True,
        ),
        "package_manager_generator": attr.label(
            default = Label("//package_managers/apt_get:default_docker_packages"),
            executable = True,
            cfg = "target",
            allow_files = True,
            single_file = True,
        ),
    },
    executable = False,
    outputs = {
        #        "out": "%{name}.tar",
        "out": "%{name}.file",
    },
    implementation = _impl,
)
