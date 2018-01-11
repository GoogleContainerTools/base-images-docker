package(default_visibility = ["//visibility:public"])

exports_files(glob(["*.yaml"]))

load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")

container_test(
    name = "ubuntu_test",
    configs = [":ubuntu_test.yaml"],
    image = "//ubuntu:ubuntu_16_0_4",
)

container_test(
    name = "ubuntu_build_test",
    configs = [":ubuntu_build_test.yaml"],
    image = "//ubuntu:ubuntu_16_0_4_build",
)
