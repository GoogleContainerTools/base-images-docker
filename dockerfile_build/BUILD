package(default_visibility = ["//:__subpackages__"])

load(":dockerfile_build.bzl", "dockerfile_build")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

pkg_tar(
    name = "context",
    srcs = glob(["context/**/*"]),
    package_dir = "/",
    strip_prefix = "context/",
)

dockerfile_build(
    name = "test_image",
    base = "//reproducible:debian8",
    context = ":context.tar",
    dockerfile = ":Dockerfile",
)

dockerfile_build(
    name = "test_image_2",
    base_tar = ":test_image",
    dockerfile = ":Dockerfile.2",
)

py_binary(
    name = "config_stripper",
    srcs = ["config_stripper.py"],
)

dockerfile_build(
    name = "ubuntu_16_0_4",
    base = "//reproducible/ubuntu:ubuntu_16_0_4_vanilla",
    dockerfile = ":Dockerfile.ubuntu",
)

dockerfile_build(
    name = "ubuntu_16_0_4_build",
    base = "//reproducible/ubuntu:ubuntu_16_0_4",
    dockerfile = ":Dockerfile.ubuntu_build",
)
