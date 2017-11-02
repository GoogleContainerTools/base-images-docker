package(default_visibility = ["//visibility:public"])

exports_files(glob(["*.yaml"]))

load("@runtimes_common//structure_tests:tests.bzl", "structure_test")

structure_test(
    name = "ubuntu_test",
    config = "//tests/ubuntu:ubuntu_test.yaml",
    image = "//ubuntu/reproducible:ubuntu",
)
