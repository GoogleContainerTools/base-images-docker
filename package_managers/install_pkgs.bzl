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

cid=$(docker run -d --privileged {image_name} /bin/bash)
docker attach $cid
docker cp {installables}.tar $cid:/

tar -tvf {installables}.tar
dpkg -i {installables}/*.deb
apt-get install -file
docker commit $cid
ubuntu:{sha}
docker save {sha} > {output}
""".format(image_tar=,
           installables=,
           sha=,
           output=
  )
  
  ctx.actions.write(
    output=ctx.outputs.executable,
    content=build_contents,
  )
  return struct(
  
  )




_install_pkgs = rule(
  attrs = {
    "image_tar": attr_label(
      default = Label("//ubuntu:ubuntu_16_0_4_vanilla.tar")
      allow_files = True,
      executable = True,
      cfg = "target",
    ),
    "installables_tar": attr_label(
      default = Label("//package_managers:download_pkgs")
      allow_files = True,
      executable = True,
      cfg = "target",
    )
  },
  executable = True,
  implementation = _impl,
)

def download_image_pkgs(name, base, installables):
  