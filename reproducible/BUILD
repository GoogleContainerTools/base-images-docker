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
    name = "jessie_base",
    distro = "jessie",
)

debootstrap_image(
    name = "stretch_base",
    distro = "stretch",
)

debootstrap_image(
    name = "buster_base",
    distro = "buster",
)

docker_build(
    name = "debian8",
    base = ":jessie_base",
    tars = [
        ":overlay.tar",
    ],
)

docker_build(
    name = "debian9",
    base = ":stretch_base",
    tars = [
        ":overlay.tar",
    ],
)

docker_build(
    name = "debian10",
    base = ":buster_base",
    tars = [
        ":overlay.tar",
    ],
)

structure_test(
    name = "debian8_test",
    config = "//tests:debian_test.yaml",
    image = ":debian8",
)

structure_test(
    name = "debian9_test",
    config = "//tests:debian_test.yaml",
    image = ":debian9",
)

structure_test(
    name = "debian10_test",
    config = "//tests:debian_test.yaml",
    image = ":debian10",
)
