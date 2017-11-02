package(default_visibility = ["//visibility:public"])

load("//dockerfile_build:dockerfile_build.bzl", "dockerfile_build")

dockerfile_build(
    name = "ubuntu_build",
    base = "//ubuntu/reproducible:ubuntu",
    context = "//dockerfile_build:context",
    dockerfile = ":Dockerfile.ubuntu_build",
)
