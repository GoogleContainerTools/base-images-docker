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
  unstripped_tar = ctx.actions.declare_file(ctx.outputs.out.basename + ".unstripped")

  build_contents = """\
#!/bin/bash
set -ex
docker load --input {base_image_tar}

cid=$(docker run -d -v $(pwd)/{installables_tar}:/tmp/installables.tar -v $(pwd)/{installer_script}:/tmp/installer.sh --privileged {base_image_name} /tmp/installer.sh)

docker attach $cid
docker commit -c 'CMD /bin/bash' $cid {output_image_name}
docker save {output_image_name} > {output_file_name}
""".format(base_image_tar=ctx.file.image_tar.path,
           base_image_name=builder_image_name,
           installables_tar=ctx.file.installables_tar.path,
           installer_script=ctx.file._installer_script.path,
           output_file_name=unstripped_tar.path,
           output_image_name=ctx.attr.output_image_name
  )

  script=ctx.actions.declare_file(ctx.label.name + ".build")
  ctx.actions.write(
    output=script,
    content=build_contents,
  )
  ctx.actions.run(
    outputs=[unstripped_tar],
    inputs=[ctx.file.image_tar, ctx.file.installables_tar, ctx.file._installer_script],
    executable=script,
  )

  ctx.actions.run(
    outputs=[ctx.outputs.out],
    inputs=[unstripped_tar],
    executable=ctx.executable._config_stripper,
    arguments=['--in_tar_path=%s' % unstripped_tar.path, '--out_tar_path=%s' % ctx.outputs.out.path],
  )


  return struct ()

install_pkgs = rule(
    attrs = {
        "image_tar": attr.label(
            default = Label("//ubuntu:ubuntu_16_0_4_vanilla.tar"),
            allow_files = True,
            single_file = True,
            mandatory = True,
        ),
        "installables_tar": attr.label(
            allow_files = True,
            single_file = True,
            mandatory = True,
        ),
        "output_image_name": attr.string(
            mandatory = True,
        ),
        "_installer_script": attr.label(
            default = Label("//package_managers:installer.sh"),
            single_file = True,
            allow_files = True,
        ),
        "_config_stripper": attr.label(
            default = "//util:config_stripper",
            executable = True,
            cfg = "host",
        ),
    },
    outputs = {
        "out": "%{name}.tar",
    },
    implementation = _impl,
)
