package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")

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

docker_build(
    name = "ubuntu_build",
    base = "//dockerfile_build:ubuntu_build.tar",
    cmd = "/bin/bash",
)

load("//reproducible/ubuntu:nodebootstrap.bzl", "nodebootstrap_image")

# nodebootstrap_image generates a .tar.gz rootfs that has has a nodejs
# install compiled from source
nodebootstrap_image(
    name = "nodejs",
)

# nodejs_ubuntu is a docker image that is a nodejs install compiled from source
# on top of a vanilla ubuntu release
docker_build(
    name = "nodejs_ubuntu",
    base = "//reproducible/ubuntu:ubuntu",
    env = NODEJS_ENV,
    ports = ["8080"],
    tars =[
        "//reproducible/ubuntu:nodejs"
    ]
)

# nodejs_ubuntu_build is a docker image that is a nodejs install compiled from
# source on top of a vanilla ubuntu release + build_essential/python2.7
docker_build(
    name = "nodejs_ubuntu_build",
    base = ":ubuntu_build",
    env = NODEJS_ENV,
    tars =[
        "//reproducible/ubuntu:nodejs"
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
