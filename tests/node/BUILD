package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")

exports_files(glob(["*.yaml"]))

container_test(
    name = "node_8_5_0_ubuntu_test",
    configs = [":node_8_5_0_ubuntu_test.yaml"],
    image = "//node/reproducible:node_8_5_0_ubuntu_16_0_4",
)

container_test(
    name = "node_8_5_0_ubuntu_build_test",
    configs = [":node_8_5_0_ubuntu_build_test.yaml"],
    image = "//node/reproducible:node_8_5_0_ubuntu_16_0_4_build",
)
