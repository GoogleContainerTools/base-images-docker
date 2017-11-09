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
load("//package_managers/apt:apt_get.bzl", "apt_get")
load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")
load("@io_bazel_rules_docker//skylib:filetype.bzl", "container")

def _impl(ctx):
    # build the docker image using docker build
    docker_build(
        name = "_builder_%s" ctx.attr.name,
        base = ctx.attr.base,
        entrypoint = ctx.executable.package_manager
    )
    # Generate a shell script to run apt_get inside this docker image.
    # TODO(tejaldesai): Replace this by docker_run rule
#    build_contents = """\
#!/bin/bash
#set -ex
# Run the builder image.
#cid=$(docker run -d --privileged {1})
#docker attach $cid
#tar -cvf $cid:/workspace/installables.tar.gz $cid:/workspace/installables
#docker cp $cid:/workspace/installables.tar.gz {2}
# Cleanup
#docker rm $cid
# """.format(ctx.executable._builder_image.path,
#            builder_image_name,
#            ctx.outputs.out.path)
#    script = ctx.new_file(ctx.label.name + ".build")
#    ctx.file_action(
#        output=script,
#        content=build_contents
#    )

#    ctx.actions.run(
#        outputs=[ctx.outputs.out],
#        inputs=ctx.attr._builder_image.files.to_list() +
#        ctx.attr._builder_image.data_runfiles.files.to_list() + ctx.attr._builder_image.default_runfiles.files.to_list(),
#        executable=script,
#    )

    return struct()

download_pkgs = rule(
    attrs = {
        "base": attr.label(allow_files = container),
        "bootstrap_packages": attr.string_list(),
        "package_manager": attr.label(
            default = Label("//package_managers/apt_get:apt_get"),
            executable = True,
            cfg = "target",
        ),
    },
    executable = True,
    outputs = {
        "out": "%name.tar",
    },
    implementation = _impl,
)
