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

def _generate_install_commands(tar):
  return """
tar -xvf {tar}
dpkg -i --force-depends ./*.deb
dpkg --configure -a
apt-get install -f
rm -rf /var/log
rm -rf /var/cache
touch /run/mount/utab""".format(tar=tar)

def _impl(ctx):
  installables_tar = ctx.file.installables_tar.path
  # Generate the installer.sh script
  install_script = ctx.new_file("%s.install" % (ctx.label.name))
  ctx.template_action(
      template=ctx.file._installer_tpl,
      substitutions= {
          "%{install_commands}": _generate_install_commands(installables_tar),
          "%{installables_tar}": installables_tar,
      },
      output = install_script,
      executable = True,
  )

  builder_image_name = "bazel/%s:%s" % (ctx.attr.image_tar.label.package,
                                        ctx.attr.image_tar.label.name.split(".tar")[0])
  unstripped_tar = ctx.actions.declare_file(ctx.outputs.out.basename + ".unstripped")

  build_contents = """\
#!/bin/bash
set -ex
# Load utils
source {util_script}

docker load --input {base_image_tar}

cid=$(docker run -d -v $(pwd)/{installables_tar}:/tmp/{installables_tar} -v $(pwd)/{installer_script}:/tmp/installer.sh --privileged {base_image_name} /tmp/installer.sh)

docker attach $cid || true

reset_cmd {base_image_name} $cid {output_image_name}
docker save {output_image_name} > {output_file_name}
""".format(util_script=ctx.file._image_utils.path,
           base_image_tar=ctx.file.image_tar.path,
           base_image_name=builder_image_name,
           installables_tar=installables_tar,
           installer_script=install_script.path,
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
    inputs=[ctx.file.image_tar, install_script, ctx.file.installables_tar, ctx.file._image_utils],
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
        "_installer_tpl": attr.label(
            default = Label("//package_managers:installer.sh.tpl"),
            single_file = True,
            allow_files = True,
        ),
        "_config_stripper": attr.label(
            default = "//util:config_stripper",
            executable = True,
            cfg = "host",
        ),
        "_image_utils": attr.label(
            default = "//util:image_util.sh",
            allow_files = True,
            single_file = True,
        ),
    },
    outputs = {
        "out": "%{name}.tar",
    },
    implementation = _impl,
)
