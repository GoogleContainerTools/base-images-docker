package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")

NODEJS_ENV = {
    "PORT": "8080",
    "NODE_ENV": "production",
}

NODE_VERSIONS = [
    "8_5_0",
]

UBUNTU_VERSIONS = [
    "16_0_4",
]

# TODO(aaron-prindle) right now the compilation of node is tied to 16_0_4
# verify this is okay
sh_binary(
    name = "node_gen_tar",
    srcs = ["node_gen_tar.sh"],
    data = [
        "mknodeimage.sh",
        "//ubuntu:ubuntu_16_0_4_build.tar",
    ],
)

# node_%s_ubuntu_%s is a docker image that is a nodejs install compiled from src
# on top of a vanilla ubuntu_%s release
[[docker_build(
    name = "node_%s_ubuntu_%s" % (node_version, ubuntu_version),
    base = "//ubuntu:ubuntu_%s" % ubuntu_version,
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
    base = "//ubuntu/reproducible:ubuntu_%s_build" % ubuntu_version,
    env = NODEJS_ENV,
    tars = [
        "node_v%s_compiled.tar.gz" % node_version.replace("_", "."),
    ],
) for node_version in NODE_VERSIONS] for ubuntu_version in UBUNTU_VERSIONS]
