package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")
load(
    "@package_bundle//file:packages.bzl",
    builder_packages = "packages",
)
load("@runtimes_common//structure_tests:tests.bzl", "structure_test")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

# TODO: Try to reuse this variable from WORKSPACE.
# The Debian snapshot datetime to use. See http://snapshot.debian.org/ for more information.
SNAPSHOT = "20170816T214423Z"

docker_build(
    name = "builder",
    base = "@debian_base//image",
    cmd = [SNAPSHOT],
    debs = builder_packages.values(),
    entrypoint = ["/mkimage.sh"],
    files = [":mkimage.sh"],
)

# The overlay directory contains files that should be overlaid into the rootfs at /.
pkg_tar(
    name = "overlay",
    files = glob(["overlay/**/*"]),
    package_dir = "/",
    strip_prefix = "overlay/",
)

load("//reproducible:debootstrap.bzl", "debootstrap_image")

debootstrap_image(
    name = "debootstrap_base",
)

docker_build(
    name = "debian8",
    base = ":debootstrap_base",
    tars = [
        ":overlay.tar",
    ],
)

structure_test(
    name = "debian8_test",
    config = "//tests:debian_test.json",
    image = ":debian8",
)
