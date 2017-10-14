load("//rules:dockerfile_build.bzl", "dockerfile_build")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

pkg_tar(
    name = "context",
    srcs = glob(["foo/**/*"]),
    package_dir = "/",
    strip_prefix = "foo/",
)

dockerfile_build(
    name = "foo",
    base = "//reproducible:debian8.tar",
    context = ":context.tar",
    dockerfile = ":Dockerfile",
)
