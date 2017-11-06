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

""" Rules to run apt-get to install packages."""

def _impl(ctx):
  ctx.actions.run_shell(
      command = 'apt-get update -y',
      mnemonic = "FetchIndex",
  )
  install_command = 'apt-get install --no-install-recommends -y -q -o Dir::Cache="{0}" -o Dir::Cache::archives="{1}" {2}'.format(
      ctx.attr.cache_dir,
      ctx.attr.archive_dir,
      ' '.join(ctx.attr.packages))
  if ctx.attr.download_only:
      install_command += ' --download-only'
  ctx.actions.run_shell(
      command = install_command,
      mnemonic = "Install",
  )

  return struct()


#TODO(tejaldesai): Tie this to unix only
apt_get = rule(
    attrs = {
        packages: attr.string_list(doc='list of packages to download'),
        cache_dir: attr.string(default = "/var/cache/apt/", doc = 'apt-get cache directory'),
        archive_dir: attr.string(default = "archives", doc='apt-get archive directory relative to cache dir'),
        download_only: attr.bool(default=False, 
                            doc='Set true if you only want to download the package')
    },
    executable = True,
}
