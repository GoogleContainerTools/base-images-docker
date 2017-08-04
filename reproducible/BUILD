package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")
load("@package_bundle//file:packages.bzl", "packages")

docker_build(
   name = "debian8",
   tars = [":rootfs.tar.gz"],
)

# TODO: Try to reuse this variable from WORKSPACE.
# The Debian snapshot datetime to use. See http://snapshot.debian.org/ for more information.
SNAPSHOT="20170816T214423Z"

genrule(
    name ="rootfs",
    srcs=[":build.sh"],
    outs=["rootfs.tar.gz"],
    cmd="$(location build.sh) $@ %s" % SNAPSHOT,
    tools=[":builder"],
)

docker_build(
    name = "builder",
    base = "@debian_base//image",
    debs = packages.values(),
    files = [":mkimage.sh"],
)
