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

def add_apt_key(name, key, image):
    initial_image = "//package_managers:apt_key_image"

    # Image with the keyfile added
    key_image = "%s.key" % name
    docker_build(
        name=key_image,
        base=initial_image,
        directory="/tmp/gpg",
        files=[key],
    )

    # In a macro we don't get to see exactly what the key file will be named,
    # so we put it in a special directory and use glob.
    commands = [
        "apt-key add /tmp/gpg/*.gpg"
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
