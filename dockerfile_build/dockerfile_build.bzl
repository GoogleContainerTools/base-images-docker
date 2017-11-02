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

"""Rule for building debootstrap rootfs tarballs."""

def _impl(ctx):
    # Strip off the '.tar'
    base_image = ctx.attr.base.label.name.split('.', 1)[0]
    # docker_build rules always generate an image named 'bazel/$package:$name'.
    base_image_name = "bazel/%s:%s" % (ctx.attr.base.label.package,
                                       base_image)
    dockerfile_path = ctx.file.dockerfile.path
    context_path = ctx.file.context.path

    unstripped_tar = ctx.new_file(ctx.label.name + ".unstripped")
    # Generate a shell script to run the build.
    build_contents = """\
#!/bin/bash
set -ex

# Load the base image
{base_loader}


# Setup a tmpdir context
tmpdir=$(mktemp -d)
tar -xf {context} -C "$tmpdir"

# Template out the FROM line.
cat {dockerfile} | sed "s|FROM.*|FROM {base_name}|g" > "$tmpdir"/Dockerfile

# Perform the build in the context
docker build -t {tag} "$tmpdir"
# Copy out the rootfs.
docker save {tag} > {output}
 """.format(base_loader=ctx.executable.base.path,
            base_name=base_image_name,
            dockerfile=dockerfile_path,
            context=context_path,
            tag="bazel/%s:%s" % (ctx.label.package, ctx.label.name),
            output=unstripped_tar.path)
    script = ctx.new_file(ctx.label.name + ".build")
    ctx.file_action(
        output=script,
        content=build_contents
    )

    ctx.actions.run(
        outputs=[unstripped_tar],
        inputs=ctx.attr.base.files.to_list() + ctx.attr.dockerfile.files.to_list() + ctx.attr.context.files.to_list() +
        ctx.attr.base.data_runfiles.files.to_list() + ctx.attr.base.default_runfiles.files.to_list(),
        executable=script,
    )


    ctx.actions.run(
        outputs=[ctx.outputs.out],
        inputs=[unstripped_tar],
        executable=ctx.executable._config_stripper,
        arguments=['--in_tar_path=%s' % unstripped_tar.path, '--out_tar_path=%s' % ctx.outputs.out.path],
    )

    return struct()

dockerfile_build = rule(
    attrs = {
        "base": attr.label(
            allow_files = True,
            single_file = True,
            executable = True,
            cfg = "target",
        ),
        "dockerfile": attr.label(
            allow_files = True,
            single_file = True,
            mandatory = True,
        ),
        "context": attr.label(
            allow_files = True,
            single_file = True,
            mandatory = True,
        ),
        "_config_stripper": attr.label(
            cfg = "host",
            executable = True,
            default = "//util:config_stripper",
        ),
    },
    executable = False,
    outputs = {
        "out": "%{name}.tar",
    },
    implementation = _impl,
)
