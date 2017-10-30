package(default_visibility = ["//visibility:public"])

load("@runtimes_common//structure_tests:tests.bzl", "structure_test")

structure_test(
    name = "ubuntu_test",
    config = "//tests:ubuntu_test.yaml",
    image = "//reproducible/ubuntu:ubuntu_16_0_4",
)

structure_test(
    name = "ubuntu_build_test",
    config = "//tests:ubuntu_build_test.yaml",
    image = "//reproducible/ubuntu:ubuntu_16_0_4_build",
)

structure_test(
    name = "node_8_5_0_ubuntu_test",
    config = "//tests:node_8_5_0_ubuntu_test.yaml",
    image = "//reproducible/ubuntu:node_8_5_0_ubuntu",
)

structure_test(
    name = "node_8_5_0_ubuntu_build_test",
    config = "//tests:node_8_5_0_ubuntu_build_test.yaml",
    image = "//reproducible/ubuntu:node_8_5_0_ubuntu_build",
)
