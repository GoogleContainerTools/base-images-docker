package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")

UBUNTU_ENV = {
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

NODEJS_ENV = {
    "PORT": "8080",
    "NODE_ENV": "production",
}

docker_build(
    name = "ubuntu",
    cmd = "/bin/bash",
    env = UBUNTU_ENV,
    tars = ["@ubuntu_tar_download//file"],
)

docker_build(
    name = "ubuntu_build",
    base = "//dockerfile_build:ubuntu_build.tar",
    cmd = "/bin/bash",
)

NODE_VERSIONS = [
    "8_5_0",
]

sh_binary(
    name = "node_gen_tar",
    srcs = ["node_gen_tar.sh"],
    data = [
        "mknodeimage.sh",
        "//dockerfile_build:ubuntu_build.tar",
    ],
)

# node_%s_ubuntu is a docker image that is a nodejs install compiled from src
# on top of a vanilla ubuntu release
[docker_build(
    name = "node_%s_ubuntu" % version,
    base = "//reproducible/ubuntu:ubuntu",
    env = NODEJS_ENV,
    ports = ["8080"],
    tars = [
        "node_v%s_compiled.tar.gz" % version.replace("_", "."),
    ],
) for version in NODE_VERSIONS]

# node_%s_ubuntu_build is a docker image that is a nodejs install compiled from
# src on top of a vanilla ubuntu release + build_essential/python2.7
[docker_build(
    name = "node_%s_ubuntu_build" % version,
    base = ":ubuntu_build",
    env = NODEJS_ENV,
    tars = [
        "node_v%s_compiled.tar.gz" % version.replace("_", "."),
    ],
) for version in NODE_VERSIONS]
