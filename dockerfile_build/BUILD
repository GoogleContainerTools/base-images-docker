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

UBUNTU_VERSIONS = [
    "16_0_4",
]

[dockerfile_build(
    name = "ubuntu_%s" % version,
    base = "//reproducible/ubuntu:ubuntu_%s_vanilla" % version,
    dockerfile = ":Dockerfile.ubuntu",
) for version in UBUNTU_VERSIONS]

[dockerfile_build(
    name = "ubuntu_%s_build" % version,
    base = "//reproducible/ubuntu:ubuntu_%s" % version,
    dockerfile = ":Dockerfile.ubuntu_build",
) for version in UBUNTU_VERSIONS]
