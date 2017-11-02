load("//node/reproducible:nodebootstrap.bzl", "nodebootstrap_image")
load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")

NODEJS_ENV = {
    "PORT": "8080",
    "NODE_ENV": "production",
}

# nodebootstrap_image generates a .tar.gz rootfs that has has a nodejs
# install compiled from source
nodebootstrap_image(
    name = "nodejs",
)

# nodejs_ubuntu is a docker image that is a nodejs install compiled from source
# on top of a vanilla ubuntu release
docker_build(
    name = "nodejs_ubuntu",
    base = "//ubuntu/reproducible:ubuntu",
    env = NODEJS_ENV,
    ports = ["8080"],
    tars = [
        "//node/reproducible:nodejs",
    ],
)

# nodejs_ubuntu_build is a docker image that is a nodejs install compiled from
# source on top of a vanilla ubuntu release + build_essential/python2.7
docker_build(
    name = "nodejs_ubuntu_build",
    base = "//ubuntu/reproducible:ubuntu_build",
    env = NODEJS_ENV,
    tars = [
        "//node/reproducible:nodejs",
    ],
)
