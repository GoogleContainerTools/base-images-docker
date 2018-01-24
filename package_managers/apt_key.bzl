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

load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")
load("//util:run.bzl", "container_run_and_extract")

def add_apt_key(name, keys, image, gpg_image=None):
    # First build an image capable of adding an apt-key.
    # This requires the keyfile and the "gnupg package."

    # If the user specified an alternate base for this, use it.
    # Otherwise use the same base image we want the key in.

    if gpg_image == None:
        gpg_image = image

    key_image = "%s.key" % name
    docker_build(
        name=key_image,
        base=gpg_image,
        directory="/gpg",
        files=keys,
    )

    commands = [
        "apt-get update",
        "apt-get install -y -q gnupg",
        # In a macro we don't get to see exactly what the key file will be named,
        # so we put it in a special directory and use glob.
        "for file in /gpg/*; do apt-key add \$file; done"
    ]

    gpg_name="%s_gpg" % name
    container_run_and_extract(
        name=gpg_name,
        image=key_image,
        commands=commands,
        extract_file="/etc/apt/trusted.gpg"
    )

    docker_build(
        name=name,
        base=image,
        directory="/etc/apt/",
        files=[gpg_name],
    )
