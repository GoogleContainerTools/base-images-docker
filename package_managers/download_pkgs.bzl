#Copyright 2017 Google Inc. All rights reserved.

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
    # docker_build rules always generate an image named 'bazel/$package:$name'.
    builder_image_name = "bazel/%s:%s" % (ctx.attr.base.label.package,
                                          ctx.attr.base.label.name)
    # Generate a shell script to run apt_get inside this docker image.
    # TODO(tejaldesai): Replace this by docker_run rule
    build_contents = """\
#!/bin/bash
set -ex
# Run the builder image.
cid=$(docker run -d --privileged {image_name} /bin/bash)
docker attach $cid
docker cp $cid:{installables}.tar {output}.tar
# Cleanup
docker rm $cid
 """.format(image_name=builder_image_name,
            installables=ctx.attr.package_manager_generator.label.name,
            output="{0}/{1}".format(ctx.label.package, ctx.attr.name))
    ctx.actions.write(
        output=ctx.outputs.executable,
        content=build_contents,
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
    executable = True,
    implementation = _impl,
)

def download_image_pkgs(name, base, packages=[]):
   pkg_manager_target_name = "{0}_packages".format(name)
   generate_apt_get(
        name = "{0}_packages".format(name),
        cache_dir = "install",
        archive_dir = ".",
        download_only = True,
        packages = packages,
   )

   img_target_name = "{0}_build".format(name)

   docker_build(
        name = img_target_name,
        base = base,
        entrypoint = [
            "/{0}".format(pkg_manager_target_name),
        ],
        files = [":{0}".format(pkg_manager_target_name)],
   )

   download_pkgs(
       name = "{0}".format(name),
       base = ":{0}".format(img_target_name),
       package_manager_generator = ":{0}".format(pkg_manager_target_name)
   )
