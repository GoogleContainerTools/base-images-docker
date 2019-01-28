package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")
load(
    "@package_bundle//file:packages.bzl",
    builder_packages = "packages",
)
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

# TODO: Try to reuse this variable from WORKSPACE.
# The Debian snapshot datetime to use. See http://snapshot.debian.org/ for more information.
DEB_SNAPSHOT = "20190124T154325Z"

docker_build(
    name = "builder",
    base = "@debian_base//image",
    debs = builder_packages.values(),
    entrypoint = [
        "/mkimage.sh",
        DEB_SNAPSHOT,
    ],
    files = [":mkimage.sh"],
)

# The overlay directory contains files that should be overlaid into the rootfs at /.
pkg_tar(
    name = "overlay",
    srcs = glob(["overlay/**/*"]),
    package_dir = "/",
    strip_prefix = "overlay/",
)

load("//debian/reproducible:debootstrap.bzl", "debootstrap_image")

DEBIAN_ENV = {
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    "PORT": "8080",
    "DEBIAN_FRONTEND": "noninteractive",
}

DEBIAN_MAP = {
    8: "jessie",
    9: "stretch",
}

[debootstrap_image(
    name = "debian%s" % num,
    distro = distro,
    env = DEBIAN_ENV,
    overlay_tar = ":overlay.tar",
) for num, distro in DEBIAN_MAP.items()]
