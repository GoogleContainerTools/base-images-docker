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

load("@base_images_docker//util:run.bzl", "container_run_and_extract")
load("@io_bazel_rules_docker//container:container.bzl", "container_image")

"""Rule for building debootstrap rootfs tarballs."""

def debootstrap_image(
        name,
        builder_image,
        snapshot,
        variant = "minbase",
        distro = "stretch",
        overlay_tar = None,
        env = None):
    if not env:
        env = {}

    rootfs = "%s.rootfs" % name

    container_run_and_extract(
        name = rootfs,
        commands = [
            " ".join(["/mkimage.sh", snapshot, variant, distro]),
        ],
        extract_file = "/workspace/rootfs.tar.gz",
        image = builder_image,
        docker_run_flags = ["--privileged"],
    )

    tars = [":" + rootfs + "/workspace/rootfs.tar.gz"]

    if overlay_tar:
        # The overlay tar has to come first to actuall overwrite existing files.
        tars.insert(0, overlay_tar)

    container_image(
        name = name,
        tars = tars,
        env = env,
        cmd = "/bin/bash",
    )
