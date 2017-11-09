package(default_visibility = ["//visibility:public"])

load("//dockerfile_build:dockerfile_build.bzl", "dockerfile_build")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")

UBUNTU_VERSIONS = [
    "16_0_4",
]

[dockerfile_build(
    name = "ubuntu_%s_dockerbuild" % version,
    base = ":ubuntu_%s_vanilla" % version,
    dockerfile = ":Dockerfile.ubuntu",
) for version in UBUNTU_VERSIONS]

[dockerfile_build(
    name = "ubuntu_%s_build_dockerbuild" % version,
    base = ":ubuntu_%s" % version,
    dockerfile = ":Dockerfile.ubuntu_build",
) for version in UBUNTU_VERSIONS]

UBUNTU_ENV = {
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

# The overlay directory contains files that should be overlaid into the rootfs at /.
pkg_tar(
    name = "overlay",
    srcs = glob(["overlay/**/*"]),
    package_dir = "/",
    strip_prefix = "overlay/",
)

# 'ubuntu_%s_vanilla' is docker image derived from a snapshot ubuntu_%s rootfs
[docker_build(
    name = "ubuntu_%s_vanilla" % version,
    env = UBUNTU_ENV,
    tars = ["@ubuntu_%s_tar_download//file" % version],
) for version in UBUNTU_VERSIONS]

# 'ubuntu_%s' is a ubuntu_%s rootfs w/ ca-certificates, curl, and netbase
[docker_build(
    name = "ubuntu_%s" % version,
    base = "//ubuntu:ubuntu_%s_dockerbuild.tar" % version,
    tars = [
        ":overlay.tar",
    ],
) for version in UBUNTU_VERSIONS]

# 'ubuntu_%s_build' is the 'ubuntu_%s' image w/ build-essential and python2.7
[docker_build(
    name = "ubuntu_%s_build" % version,
    base = "//ubuntu:ubuntu_%s_build_dockerbuild.tar" % version,
) for version in UBUNTU_VERSIONS]
