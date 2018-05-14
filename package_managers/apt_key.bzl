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

"""Rule for configuring apt GPG keys"""

load("@io_bazel_rules_docker//container:container.bzl", _container = "container")
load("@base_images_docker//util:run.bzl", _extract = "extract")

def _impl(ctx, name=None, keys=None, image_tar=None, gpg_image=None, output_executable=None, output_tarball=None, output_layer=None):
    """Implementation for the add_apt_key rule.

    Args:
        ctx: The bazel rule context
        name: str, overrides ctx.label.name
        keys: File list, overrides ctx.files.keys
        image_tar: File, overrides ctx.file.image
        gpg_image: File, overrides ctx.file.gpg_image
        output_executable: File to use as output for script to load docker image,
            overrides ctx.outputs.executable
        output_tarball: File, overrides ctx.outputs.out
        output_layer: File, overrides ctx.outputs.layer
    """
    name = name or ctx.label.name
    keys = keys or ctx.files.keys
    image_tar = image_tar or ctx.file.image_tar
    gpg_image = gpg_image or ctx.file.gpg_image
    output_executable = output_executable or ctx.outputs.executable
    output_tarball = output_tarball or ctx.outputs.out
    output_layer = output_layer or ctx.outputs.layer

    # First build an image capable of adding an apt-key.
    # This requires the keyfile and the "gnupg package."

    # If the user specified an alternate base for this, use it.
    # Otherwise use the same base image we want the key in.
    if gpg_image == None:
        gpg_image = image_tar

    key_image = "%s.key" % name
    key_image_output_executable = ctx.actions.declare_file("%s" % key_image)
    key_image_output_tarball = ctx.actions.declare_file("%s.tar" % key_image)
    key_image_output_layer = ctx.actions.declare_file("%s-layer.tar" % key_image)

    key_image_result = _container.image.implementation(
        ctx,
        name=key_image,
        base=gpg_image,
        directory="/gpg",
        files=keys,
        output_executable=key_image_output_executable,
        output_tarball=key_image_output_tarball,
        output_layer=key_image_output_layer
    )

    commands = [
        "apt-get update",
        "apt-get install -y -q gnupg",
        # Put keys in a special directory and use glob.
        "for file in /gpg/*; do apt-key add \$file; done"
    ]
    extract_file_name = "/etc/apt/trusted.gpg"
    extract_file_out = ctx.actions.declare_file(name + "-trusted.gpg")

    # container_image rules always generate an image named 'bazel/$package:$name'.
    image_name = "bazel/%s:%s" % (key_image_output_tarball.owner.package,
                                  key_image_output_tarball.basename.split(".tar")[0])

    _extract.implementation(
        ctx,
        name = name,
        image_tar = key_image_output_tarball,
        image_name = image_name,
        commands = commands,
        extract_file = extract_file_name,
        output_file = extract_file_out,
    )

    # Build the final image with additional gpg keys in it.

    result = _container.image.implementation(
        ctx,
        name=name,
        base=image_tar,
        directory="/etc/apt/trusted.gpg.d/",
        files=[extract_file_out],
        output_executable=output_executable,
        output_tarball=output_tarball,
        output_layer=output_layer
    )

    return struct(runfiles = result.runfiles,
                  files = result.files,
                  container_parts = result.container_parts)


_attrs = _container.image.attrs + _extract.attrs + {
    "keys": attr.label_list(
        allow_files = True,
        mandatory = True,
    ),
    "gpg_image": attr.label(
        allow_files = True,
        single_file = True,
    ),
    # Redeclare following attributes of _extract to be non-mandatory.
    "image_name": attr.string(doc = "name of image to run commands on"),
    "commands": attr.string_list(doc = "commands to run"),
    "extract_file": attr.string(doc = "path to file to extract from container"),
    "output_file": attr.string()
}

_outputs = _container.image.outputs

# Export add_apt_key rule for other bazel rules to depend on.
key = struct(
    attrs = _attrs,
    outputs = _outputs,
    implementation = _impl,
)

add_apt_key = rule(
    attrs = _attrs,
    outputs = _outputs,
    implementation = _impl,
    executable = True,
)
