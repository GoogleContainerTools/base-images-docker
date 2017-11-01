package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

UBUNTU_ENV = {
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

NODEJS_ENV = {
    "PORT": "8080",
    "NODE_ENV": "production",
}

# The overlay directory contains files that should be overlaid into the rootfs at /.
pkg_tar(
    name = "overlay",
    files = glob(["overlay/**/*"]),
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
    base = "//dockerfile_build:ubuntu_%s.tar" % version,
    tars = [
        ":overlay.tar",
    ],
) for version in UBUNTU_VERSIONS]

# 'ubuntu_%s_build' is the 'ubuntu_%s' image w/ build-essential and python2.7
[docker_build(
    name = "ubuntu_%s_build" % version,
    base = "//dockerfile_build:ubuntu_%s_build.tar" % version,
) for version in UBUNTU_VERSIONS]

NODE_VERSIONS = [
    "8_5_0",
]

# TODO(aaron-prindle) right now the compilation of node is tied to 16_0_4
# verify this is okay
sh_binary(
    name = "node_gen_tar",
    srcs = ["node_gen_tar.sh"],
    data = [
        "mknodeimage.sh",
        "//dockerfile_build:ubuntu_16_0_4_build.tar",
    ],
)

# node_%s_ubuntu_%s is a docker image that is a nodejs install compiled from src
# on top of a vanilla ubuntu_%s release
[[docker_build(
    name = "node_%s_ubuntu_%s" % (node_version, ubuntu_version),
    base = "//dockerfile_build:ubuntu_%s" % ubuntu_version,
    env = NODEJS_ENV,
    ports = ["8080"],
    tars = [
        "node_v%s_compiled.tar.gz" % node_version.replace("_", "."),
    ],
) for node_version in NODE_VERSIONS] for ubuntu_version in UBUNTU_VERSIONS]

# node_%s_ubuntu_%s_build is a docker image that is a nodejs install compiled from
# src on top of a vanilla ubuntu_%s release + build_essential/python2.7
[[docker_build(
    name = "node_%s_ubuntu_%s_build" % (node_version, ubuntu_version),
    base = ":ubuntu_%s_build" % ubuntu_version,
    env = NODEJS_ENV,
    tars = [
        "node_v%s_compiled.tar.gz" % node_version.replace("_", "."),
    ],
) for node_version in NODE_VERSIONS] for ubuntu_version in UBUNTU_VERSIONS]
