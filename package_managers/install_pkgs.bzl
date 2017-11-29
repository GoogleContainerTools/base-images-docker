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

"""Rule for installing apt packages from a tar file into a docker image."""

def _impl(ctx):
  builder_image_name = "bazel/%s:%s" % (ctx.attr.image_tar.label.package,
                                        ctx.attr.image_tar.label.name.split(".tar")[0])

  build_contents = """\
#!/bin/bash
set -ex
docker load --input {image_tar}

cid=$(docker run -d -v {installables}.tar:/tmp/installables.tar,{installer}:/tmp/installer.sh --privileged {image_name} /tmp/installer.sh)

docker attach $cid
docker commit $cid {output_image_name}
docker save {output_image_name} > {output_file_name}.tar
""".format(image_tar="{0}/{1}".format(ctx.label.package, ctx.attr.image_tar.label.name),
           installables=ctx.attr.installables_tar.label.name,
           output_file_name=ctx.attr.name,
           installer=ctx.attr._installer_script.label.name,
           image_name=builder_image_name,
           output_image_name="installed_package_image_thing"
  )

  ctx.actions.write(
    output=ctx.outputs.executable,
    content=build_contents,
  )
  return struct ()

install_pkgs = rule(
  attrs = {
    "image_tar": attr.label(
        default = Label("//ubuntu:ubuntu_16_0_4_vanilla.tar"),
        allow_files = True,
        single_file = True,
        mandatory = True
    ),
    "installables_tar": attr.label(
        allow_files = True,
        single_file = True,
        mandatory = True
    ),
    "output_image_name": attr.string(
        mandatory = True
    ),
    "_installer_script": attr.label(
        default = Label("//package_managers:installer.sh"),
        allow_files = True
    )
  },
  executable = True,
  implementation = _impl,
)
