package(default_visibility = ["//:__subpackages__"])

load(":dockerfile_build.bzl", "dockerfile_build")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load("@runtimes_common//structure_tests:tests.bzl", "structure_test")

pkg_tar(
    name = "context",
    srcs = glob(["context/**/*"]),
    package_dir = "/",
    strip_prefix = "context/",
)

dockerfile_build(
    name = "test_image",
    base = "//reproducible:debian8.tar",
    context = ":context.tar",
    dockerfile = ":Dockerfile",
)

structure_test(
    name = "dockerfile_build_test",
    config = ":test.yaml",
    image_tar = ":test_image",
)

py_binary(
    name = "config_stripper",
    srcs = ["config_stripper.py"],
)

dockerfile_build(
    name = "ubuntu_build",
    base = "//reproducible:ubuntu.tar",
    context = ":context.tar",
    dockerfile = ":Dockerfile.ubuntu_build",
)
