package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")
load("@package_bundle//file:packages.bzl", "packages")
load("@runtimes_common//structure_tests:tests.bzl", "structure_test")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")


# TODO: Try to reuse this variable from WORKSPACE.
# The Debian snapshot datetime to use. See http://snapshot.debian.org/ for more information.
SNAPSHOT="20170816T214423Z"

docker_build(
    name = "builder",
    base = "@debian_base//image",
    debs = packages.values(),
    files = [":mkimage.sh"],
    entrypoint = ["/mkimage.sh"],
    cmd = [SNAPSHOT],
)

pkg_tar(
    name="sources_list",
    files=[":sources.list"],
    package_dir="/etc/apt"
)

pkg_tar(
    name="apt_retries",
    files=[":apt_retry"],
    package_dir="/etc/apt/apt.conf.d/"
)

# This rule expects that you've created a rootfs.tar.gz at the root of this repo yourself somehow.
# TODO: figure out how to generate this in bazel somehow.
docker_build(
   name = "debian8",
   tars = [ ":sources_list.tar",
            ":apt_retries.tar",
            "//:rootfs.tar.gz"],
)

structure_test(
    name = "debian8_test",
    config = "//tests:debian_test.json",
    image = ":debian8",
)