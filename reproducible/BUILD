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
SNAPSHOT = "20171017T102456Z"

docker_build(
    name = "builder",
    base = "@debian_base//image",
    debs = builder_packages.values(),
    entrypoint = [
        "/mkimage.sh",
        SNAPSHOT,
    ],
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

DEBIAN_ENV = {
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    "PORT": "8080",
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

[structure_test(
    name = "debian%s_test" % num,
    config = "//tests:debian_test.yaml",
    image = ":debian%s" % num,
) for num, distro in DEBIAN_MAP.items()]

[structure_test(
    name = "debian%s_version_test" % num,
    config = "//tests:debian_%s_test.yaml" % num,
    image = ":debian%s" % num,
) for num, distro in DEBIAN_MAP.items()]

UBUNTU_ENV = {
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

NODEJS_ENV = {
    "PORT": "8080",
    "NODE_ENV": "production"
}

docker_build(
    name = "ubuntu",
    cmd = "/bin/bash",
    env = UBUNTU_ENV,
    tars = ["@ubuntu_tar_download//file"],
)

structure_test(
    name = "ubuntu_test",
    config = "//tests:ubuntu_test.yaml",
    image = ":ubuntu",
)

docker_build(
    name = "ubuntu_build",
    base = "//dockerfile_build:ubuntu_build.tar",
    cmd = "/bin/bash",
)

load("//reproducible:nodebootstrap.bzl", "nodebootstrap_image")

# nodebootstrap_image generates a .tar.gz rootfs that has has a nodejs
# install compiled from source
nodebootstrap_image(
    name = "nodejs",
)

# nodejs_ubuntu is a docker image that is a nodejs install compiled from source
# on top of a vanilla ubuntu release
docker_build(
    name = "nodejs_ubuntu",
    base = "//reproducible:ubuntu",
    env = NODEJS_ENV,
    ports = ["8080"],
    tars =[
        "//reproducible:nodejs"
    ]
)

# nodejs_ubuntu_build is a docker image that is a nodejs install compiled from
# source on top of a vanilla ubuntu release + build_essential/python2.7
docker_build(
    name = "nodejs_ubuntu_build",
    base = ":ubuntu_build",
    env = NODEJS_ENV,
    tars =[
        "//reproducible:nodejs"
    ]
)

# nodejs_builder is a docker image that is capable of building nodejs running
# the mknodeimage.sh script on top of ubuntu + build_essential/python2.7
docker_build(
    name = "nodejs_builder",
    base = ":ubuntu_build",
    entrypoint = [
        "/mknodeimage.sh",
    ],
    files = [
        ":mknodeimage.sh",
        "@nodejs_tar_download//file"
        ],
)
