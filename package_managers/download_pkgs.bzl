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

load("//package_managers/apt_get:repos.bzl", "generate_additional_repos")
load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")

def _generate_download_commands(ctx):
    return """#!/bin/bash
set -ex
# Fetch Index
apt-get update -y
# Make partial dir
mkdir -p /tmp/install/./partial
# Install command
apt-get install --no-install-recommends -y -q -o Dir::Cache="/tmp/install" -o Dir::Cache::archives="." {packages} --download-only
# Tar command to only include all the *.deb files and ignore other directories placed in the cache dir.
tar -cpf {output}.tar --directory /tmp/install/. `cd /tmp/install/. && ls *.deb`""".format(
    output=ctx.attr.name,
    packages=' '.join(ctx.attr.packages))

def _run_download_script(ctx, output, build_contents):
    download_script = ctx.actions.declare_file("{0}_download".format(ctx.attr.name))
    contents = build_contents.replace(ctx.file.image_tar.short_path, ctx.file.image_tar.path)
    contents = contents.replace(ctx.outputs.pkg_tar.short_path, ctx.outputs.pkg_tar.path)
    # The paths for running within bazel build are different and hence replace short_path
    # by full path
    ctx.actions.write(
        output = download_script,
        content = contents,
    )

    ctx.actions.run(
        outputs = [ctx.outputs.pkg_tar],
        executable = download_script,
        inputs = [ctx.file.image_tar],
    )

def _impl(ctx):
    # docker_build rules always generate an image named 'bazel/$package:$name'.
    builder_image_name = "bazel/%s:%s" % (ctx.attr.image_tar.label.package,
                                          ctx.attr.image_tar.label.name.split(".tar")[0])

    # Generate a shell script to run apt_get inside this docker image.
    # TODO(tejaldesai): Replace this by docker_run rule
    build_contents = """\
#!/bin/bash
set -ex
docker load --input {image_tar}
# Run the builder image.
cid=$(docker run -d --privileged {image_name} sh -c $'{download_commands}')
docker attach $cid
docker cp $cid:{installables}.tar {output}
# Cleanup
docker rm $cid
 """.format(image_tar=ctx.file.image_tar.short_path,
            image_name=builder_image_name,
            installables=ctx.attr.name,
            download_commands=_generate_download_commands(ctx),
            output=ctx.outputs.pkg_tar.short_path,
            )
    _run_download_script(ctx, ctx.outputs.pkg_tar, build_contents)
    ctx.actions.write(
        output = ctx.outputs.executable,
        content = build_contents,
    )

    return struct(
        runfiles = ctx.runfiles(files = [ctx.file.image_tar,]),
        files = depset([ctx.outputs.executable])
    )

_download_pkgs = rule(
    attrs = {
        "image_tar": attr.label(
            default = Label("//ubuntu:ubuntu_16_0_4_vanilla.tar"),
            allow_files = True,
            single_file = True,
        ),
        "packages": attr.string_list(
            mandatory = True,
        ),
    },
    executable = True,
    outputs = {
        "pkg_tar": "%{name}.tar",
    },
    implementation = _impl,
)

"""Downloads packages within a container

This rule creates a script to download packages within a container.
It also run the script and produces the tarball if requested.
The script bunldes all the packages in a tarball.

Args:
  name: A unique name for this rule.
  image_tar: The image tar for the container used to download packages.
  package_manager_genrator: A target which generates a script using
       package management tool e.g apt-get, dpkg to downloads packages.
  additional_repos: list of additional debian package repos to use, in sources.list format
"""

def download_pkgs(name, image_tar, packages, additional_repos=[]):
  """Downloads packages within a container
  This rule creates a script to download packages within a container.
  The script bunldes all the packages in a tarball.
  Args:
    name: A unique name for this rule.
    image_tar: The image tar for the container used to download packages.
    package_manager_genrator: A target which generates a script using
      package management tool e.g apt-get, dpkg to downloads packages.
    packages: list of packages to download. e.g. ['curl', 'netbase']
    additional_repos: list of additional debian package repos to use, in sources.list format
  """
  tars = []
  if additional_repos:
    repo_name="{0}_repos".format(name)
    generate_additional_repos(
        name = repo_name,
        repos = additional_repos
    )
    tars.append("%s.tar" % repo_name)


  img_target_name = "{0}_build".format(name)
  docker_build(
        name = img_target_name,
        base = image_tar,
        tars = tars,
  )
  _download_pkgs(
       name = "{0}".format(name),
       image_tar = ":{0}.tar".format(img_target_name),
       packages = packages,
  )
