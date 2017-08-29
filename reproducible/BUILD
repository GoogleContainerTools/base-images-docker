package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")
load(
    "@package_bundle//file:packages.bzl",
    builder_packages = "packages",
)
load(
    "@image_package_bundle//file:packages.bzl",
    image_packages = "packages",
)
load("@runtimes_common//structure_tests:tests.bzl", "structure_test")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load("@distroless//cacerts:cacerts.bzl", "cacerts")

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

pkg_tar(
    name = "sources_list",
    files = [":sources.list"],
    package_dir = "/etc/apt",
)

pkg_tar(
    name = "apt_retries",
    files = [":apt-retry"],
    package_dir = "/etc/apt/apt.conf.d/",
)

# This file was generated once by debootstrap and then committed here.
pkg_tar(
    name = "machine_id",
    files = [":machine-id"],
    package_dir = "/etc/",
)

cacerts(
    name = "cacerts",
)

load("//reproducible:debootstrap.bzl", "debootstrap_image")

debootstrap_image(
    name = "debootstrap_base",
)

docker_build(
    name = "debian8",
    base = ":debootstrap_base",
    debs = image_packages.values(),
    tars = [
        ":sources_list.tar",
        ":apt_retries.tar",
        ":cacerts.tar",
        ":machine_id.tar",
    ],
)

structure_test(
    name = "debian8_test",
    config = "//tests:debian_test.json",
    image = ":debian8",
)
