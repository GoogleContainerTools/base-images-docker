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

"""Rule for bootstrapping an image from using download_pkgs and install_pkgs """

load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")

load("//package_managers:download_pkgs.bzl", "download_pkgs")
load("//package_managers:install_pkgs.bzl", "install_pkgs")

PACKAGES_FILE_NAME = "packages.tar"
# Load all the stores get and put.
load("//store/git:git.bzl",
     "git_store_get",
     "git_store_put",
     _git_store_tools = "tools")

def _impl(ctx):
    store_key = "{0}/{1}".format(ctx.attr.date, PACKAGES_FILE_NAME)
 
    get_status = git_store_get(
        ctx = ctx,
        store_location = ctx.attr.store_location,
        key = store_key,
        artifact = "{0}/{1}".format(ctx.bin_dir.path, PACKAGES_FILE_NAME),
    )
    download_pkgs_file_prefix = ctx.executable.download_pkgs.path
    build_contents = """
set -ex
EXIT_CODE=`cat {get_status}`
if [ $EXIT_CODE != 0 ]; then
  echo "Could not find the artifact {key} in store defined at {store_location}"
  echo "Running download_pkgs script"
  {download_pkgs_script}
  cp {download_pkgs_tar} {output}
else
  GIT_ROOT=`printenv GIT_ROOT`
  cp $GIT_ROOT/{output_dir}/{packages} {output}
fi
""".format(
       output = ctx.outputs.packages_tar.path,
       download_pkgs_script = "{0}.sh".format(download_pkgs_file_prefix),
       download_pkgs_tar = "{0}.tar".format(download_pkgs_file_prefix),
       key = store_key,
       store_location = ctx.attr.store_location,
       output_dir = ctx.bin_dir.path,
       get_status = get_status.path,
       packages = PACKAGES_FILE_NAME,
    )

    fetch_or_download = ctx.actions.declare_file("fetch_or_download")
    ctx.actions.write(
        output = fetch_or_download,
        content = build_contents,
        is_executable = True,
    )
    
    ctx.actions.run(
        outputs = [ctx.outputs.packages_tar],
        inputs = ctx.attr.download_pkgs.default_runfiles.files.to_list() +
                 [get_status,
                  ctx.file.image_tar, fetch_or_download, ],
        executable = fetch_or_download,
        mnemonic = "RunFetchOrDownload",
        use_default_shell_env = True,
    )
    # this is not executed when you call the install_pkgs rule. 
    # Only gets executed when you run _fetch target
    put_status = git_store_put(
        ctx = ctx,
        store_location = ctx.attr.store_location,
        artifact = ctx.outputs.packages_tar,
        key = store_key
    )

    return struct(
        files = depset([ctx.outputs.packages_tar,]),
        runfiles = ctx.runfiles(files = ctx.attr.download_pkgs.default_runfiles.files.to_list() +
                                        [put_status, 
                                         ctx.file.image_tar])
    )

fetch_or_download_pkgs = rule(
    attrs = dict({
        "image_tar": attr.label(
            default = Label("//ubuntu:ubuntu_16_0_4_vanilla.tar"),
            allow_files = True,
            single_file = True,
        ),
       "download_pkgs": attr.label(
            cfg = "target",
            executable = True,
            allow_files = True,
        ),
       "store_location": attr.string(),
       "date": attr.string(), 
       "output_image_name": attr.string(),
    }.items() + _git_store_tools.items()),
    outputs = {
      "packages_tar": "%{name}.tar",
    },
    implementation = _impl,
)



"""Bootstrap images with packages from package manager or given location.

This rule builds an image with packages either by downloading packages from
package manager or given location.

Args:
  name: A unique name for this rule.
  image_tar: The image tar for the container used to download packages.
  package_manager_genrator: A target which generates a script using
       package management tool e.g apt-get, dpkg to downloads packages.
  store: A target to store the downloaded packages or retrieve previously downloaded packages.
  additional_repos: list of additional debian package repos to use, in sources.list format
"""

def bootstrap_image_macro(name, image_tar, packages, store_location, date, output_image_name, additional_repos=[]):
  """Downloads packages within a container
  This rule creates a script to download packages within a container.
  The script bunldes all the packages in a tarball.
  Args:
    name: A unique name for this rule.
    image_tar: The image tar for the container used to download packages.
    packages: list of packages to download. e.g. ['curl', 'netbase']
    additional_repos: list of additional debian package repos to use, in sources.list format
  """

  download_pkgs(
       name = "{0}_download".format(name),
       packages = packages,
       image_tar = image_tar,
       additional_repos = additional_repos,
  )

  fetch_or_download_pkgs(
      name = "{0}_fetch".format(name),
      image_tar = image_tar,
      download_pkgs = ":{0}_download".format(name),
      store_location = store_location,
      date = date,
  )

  install_pkgs(
      name = "{0}".format(name),
      image_tar = image_tar,
      installables_tar = ":{0}_fetch.tar".format(name),
      output_image_name = output_image_name,
 )
