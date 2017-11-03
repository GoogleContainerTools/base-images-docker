package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

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

UBUNTU_VERSIONS = [
    "16_0_4",
]

# 'ubuntu_%s_vanilla' is docker image derived from a snapshot ubuntu_%s rootfs
[docker_build(
    name = "ubuntu_%s_vanilla" % version,
    cmd = "/bin/bash",
    env = UBUNTU_ENV,
    tars = ["@ubuntu_%s_tar_download//file" % version],
) for version in UBUNTU_VERSIONS]

# 'ubuntu_%s' is a ubuntu_%s rootfs w/ ca-certificates, curl, and netbase
[docker_build(
    name = "ubuntu_%s" % version,
    base = "//ubuntu:ubuntu_%s.tar" % version,
    tars = [
        ":overlay.tar",
    ],
) for version in UBUNTU_VERSIONS]

# 'ubuntu_%s_build' is the 'ubuntu_%s' image w/ build-essential and python2.7
[docker_build(
    name = "ubuntu_%s_build" % version,
    base = "//ubuntu:ubuntu_%s_build.tar" % version,
) for version in UBUNTU_VERSIONS]
