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

def _generate_add_additional_repo_commands(ctx, additional_repos):
    return """printf "{repos}" >> /etc/apt/sources.list.d/{name}_repos.list""".format(
    name=ctx.attr.name,
    repos='\n'.join(additional_repos))

def _generate_download_commands(ctx, packages, additional_repos):
    return """#!/bin/bash
set -ex
{add_additional_repo_commands}
# Remove /var/lib/apt/lists/* in the base image. apt-get update -y command will create them.
rm -rf /var/lib/apt/lists/*
# Fetch Index
apt-get update -y
# Make partial dir
mkdir -p /tmp/install/./partial
# Install command
apt-get install --no-install-recommends -y -q -o Dir::Cache="/tmp/install" -o Dir::Cache::archives="." {packages} --download-only
# Tar command to only include all the *.deb files and ignore other directories placed in the cache dir.
tar -cpf {output}.tar --mtime='1970-01-01' --directory /tmp/install/. `cd /tmp/install/. && ls *.deb`""".format(
    output=ctx.attr.name,
    packages=' '.join(packages),
    add_additional_repo_commands=_generate_add_additional_repo_commands(ctx, additional_repos))

def _run_download_script(ctx, build_contents, image_tar, output_tar, output_script, image_id_extractor):
    contents = build_contents.replace(image_tar.short_path, image_tar.path)
    contents = contents.replace(output_tar.short_path, output_tar.path)
    # The paths for running within bazel build are different and hence replace short_path
    # by full path
    ctx.actions.write(
        output = output_script,
        content = contents,
    )

    ctx.actions.run(
        outputs = [output_tar],
        executable = output_script,
        inputs = [image_tar, image_id_extractor],
    )

def _impl(ctx, image_tar=None, packages=None, additional_repos=None, output_executable=None, output_tar=None, output_script=None):
    """Implementation for the download_pkgs rule.

    Args:
        ctx: The bazel rule context
        image_tar: File, overrides ctx.file.image_tar
        packages: str List, overrides ctx.attr.packages
        additional_repos: str List, overrides ctx.attr.additional_repos
        output_executable: File, overrides ctx.outputs.executable
        output_tar: File, overrides ctx.outputs.pkg_tar
        output_script: File, overrides ctx.outputs.build_script
    """
    image_tar = image_tar or ctx.file.image_tar
    packages = packages or ctx.attr.packages
    additional_repos = additional_repos or ctx.attr.additional_repos
    output_executable = output_executable or ctx.outputs.executable
    output_tar = output_tar or ctx.outputs.pkg_tar
    output_script = output_script or ctx.outputs.build_script

    # Generate a shell script to run apt_get inside this docker image.
    # TODO(tejaldesai): Replace this by docker_run rule
    build_contents = """\
#!/bin/bash
set -ex

# Load the image and remember its name
image_id=$(python {image_id_extractor_path} {image_tar})
docker load -i {image_tar}

# Run the builder image.
cid=$(docker run -w="/" -d --privileged $image_id sh -c $'{download_commands}')
docker attach $cid
docker cp $cid:{installables}.tar {output}
# Cleanup
docker rm $cid
 """.format(image_tar=image_tar.short_path,
            installables=ctx.attr.name,
            download_commands=_generate_download_commands(ctx, packages, additional_repos),
            output=output_tar.short_path,
            image_id_extractor_path = ctx.file._image_id_extractor.path,
            )
    _run_download_script(ctx, build_contents, image_tar, output_tar, output_script, ctx.file._image_id_extractor)
    ctx.actions.write(
        output = output_executable,
        content = build_contents,
    )
    return struct(
        runfiles = ctx.runfiles(files = [image_tar, output_script, ctx.file._image_id_extractor]),
        files = depset([output_executable])
    )

_attrs = {
    "image_tar": attr.label(
        default = Label("//ubuntu:ubuntu_16_0_4_vanilla.tar"),
        allow_single_file = True,
    ),
    "packages": attr.string_list(
        mandatory = True,
    ),
    "additional_repos": attr.string_list(),
    "_image_id_extractor": attr.label(
        default = "@io_bazel_rules_docker//contrib:extract_image_id.py",
      allow_single_file = True,
    ),
}

_outputs = {
    "pkg_tar": "%{name}.tar",
    "build_script": "%{name}.sh",
}

# Export download_pkgs rule for other bazel rules to depend on.
download = struct(
    attrs = _attrs,
    outputs = _outputs,
    implementation = _impl,
)

"""Downloads packages within a container.

This rule creates a script to download packages within a container.
The script bunldes all the packages in a tarball.

Args:
  name: A unique name for this rule.
  image_tar: The image tar for the container used to download packages.
  packages: list of packages to download. e.g. ['curl', 'netbase']
  additional_repos: list of additional debian package repos to use, in sources.list format
"""

download_pkgs = rule(
    attrs = _attrs,
    executable = True,
    outputs = _outputs,
    implementation = _impl,
)
