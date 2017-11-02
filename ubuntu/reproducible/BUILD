package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")

UBUNTU_ENV = {
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

docker_build(
    name = "ubuntu",
    cmd = "/bin/bash",
    env = UBUNTU_ENV,
    tars = ["@ubuntu_tar_download//file"],
)

docker_build(
    name = "ubuntu_build",
    base = "//ubuntu:ubuntu_build.tar",
    cmd = "/bin/bash",
)
