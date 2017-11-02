package(default_visibility = ["//visibility:public"])

load(":dockerfile_build.bzl", "dockerfile_build")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

pkg_tar(
    name = "context",
    srcs = glob(["context/**/*"]),
    package_dir = "/",
    strip_prefix = "context/",
)

