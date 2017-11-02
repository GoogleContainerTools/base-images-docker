package(default_visibility = ["//visibility:public"])

load("@runtimes_common//structure_tests:tests.bzl", "structure_test")

exports_files(glob(["*.yaml"]))

structure_test(
    name = "node_8_5_0_ubuntu_test",
    config = ":node_8_5_0_ubuntu_test.yaml",
    image = "//ubuntu/reproducible:node_8_5_0_ubuntu_16_0_4",
)

structure_test(
    name = "node_8_5_0_ubuntu_build_test",
    config = ":node_8_5_0_ubuntu_build_test.yaml",
    image = "//node/reproducible:node_8_5_0_ubuntu_16_0_4_build",
)
