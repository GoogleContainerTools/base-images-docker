package(default_visibility = ["//visibility:public"])

load("//dockerfile_build:dockerfile_build.bzl", "dockerfile_build")
load("@runtimes_common//structure_tests:tests.bzl", "structure_test")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

structure_test(
    name = "dockerfile_build_test",
    config = ":test.yaml",
    image_tar = "//tests/dockerfile_build:test_image",
)

py_binary(
    name = "config_stripper",
    srcs = ["//util:config_stripper.py"],
)

pkg_tar(
    name = "context",
    srcs = glob(["context/**/*"]),
    package_dir = "/",
    strip_prefix = "context/",
)

dockerfile_build(
    name = "test_image",
    base = "//debian/reproducible:debian8",
    context = ":context.tar",
    dockerfile = ":Dockerfile",
)
