package(default_visibility = ["//:__subpackages__"])

load("//dockerfile_build:dockerfile_build.bzl", "dockerfile_build")
load("@runtimes_common//structure_tests:tests.bzl", "structure_test")

structure_test(
    name = "dockerfile_build_test",
    config = ":test.yaml",
    image_tar = "//dockerfile_build:test_image",
)

py_binary(
    name = "config_stripper",
    srcs = ["//dockerfile_build:config_stripper.py"],
)

dockerfile_build(
    name = "ubuntu_build",
    base = "//reproducible/ubuntu:ubuntu.tar",
    context = "//dockerfile_build:context.tar",
    dockerfile = "//dockerfile_build:Dockerfile.ubuntu_build",
)
