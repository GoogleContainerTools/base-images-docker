package(default_visibility = ["//visibility:public"])

load("//dockerfile_build:dockerfile_build.bzl", "dockerfile_build")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")

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

container_test(
    name = "dockerfile_build_test",
    configs = [":test.yaml"],
    image = ":test_image",
)

dockerfile_build(
    name = "test_image_2",
    base_tar = ":test_image.tar",
    dockerfile = ":Dockerfile.2",
)

container_test(
    name = "dockerfile_build_test_2",
    configs = [":test2.yaml"],
    image = ":test_image_2",
)
