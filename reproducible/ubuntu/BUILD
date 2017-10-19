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

load("//reproducible/ubuntu:node_gen_tar.bzl", "node_gen_tar")

NODE_MAP = {
    "8_5_0": "dd5ac97074882ba62892bdb91ec5e624c338d772a6218da08c182231031a4446",
    # "8_6_0": "80551d47440c602c5825a3f6611e13cb0c57d277234dbff693af433a88351a08",
}

# node_gen_tar generates a .tar.gz rootfs that has has a nodejs
# install compiled from src
[node_gen_tar(
    name = "node_%s" % version,
) for version, sha in NODE_MAP.items()]

# node_%s_ubuntu is a docker image that is a nodejs install compiled from src
# on top of a vanilla ubuntu release
[docker_build(
    name = "node_%s_ubuntu" % version,
    base = "//reproducible/ubuntu:ubuntu",
    env = NODEJS_ENV,
    ports = ["8080"],
    tars =[
        "//reproducible/ubuntu:node_%s" % version,
    ]
) for version, sha in NODE_MAP.items()]

# node_%s_ubuntu_build is a docker image that is a nodejs install compiled from
# src on top of a vanilla ubuntu release + build_essential/python2.7
[docker_build(
    name = "node_%s_ubuntu_build" % version,
    base = ":ubuntu_build",
    env = NODEJS_ENV,
    tars =[
        "//reproducible/ubuntu:node_%s" % version,
    ]
) for version, sha in NODE_MAP.items()]
