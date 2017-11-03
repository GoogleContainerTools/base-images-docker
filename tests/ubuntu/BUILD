package(default_visibility = ["//visibility:public"])

exports_files(glob(["*.yaml"]))

load("@runtimes_common//structure_tests:tests.bzl", "structure_test")

structure_test(
    name = "ubuntu_test",
    config = ":ubuntu_test.yaml",
    image = "//ubuntu/reproducible:ubuntu_16_0_4",
)

structure_test(
    name = "ubuntu_build_test",
    config = ":ubuntu_build_test.yaml",
    image = "//ubuntu/reproducible:ubuntu_16_0_4_build",
)
