package(default_visibility = ["//visibility:public"])

load("//dockerfile_build:dockerfile_build.bzl", "dockerfile_build")
load("@runtimes_common//structure_tests:tests.bzl", "structure_test")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

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

structure_test(
    name = "dockerfile_build_test",
    config = ":test.yaml",
    image_tar = ":test_image",
)

dockerfile_build(
    name = "test_image_2",
    base_tar = ":test_image",
    dockerfile = ":Dockerfile.2",
)

structure_test(
    name = "dockerfile_build_test_2",
    config = ":test2.yaml",
    image_tar = ":test_image_2",
)
