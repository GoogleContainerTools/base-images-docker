package(default_visibility = ["//visibility:public"])

load(
    "@bazel_tools//tools/build_rules:test_rules.bzl",
    "rule_test",
    "file_test",
)
load("//package_managers:download_pkgs.bzl", "download_image_pkgs")

download_image_pkgs(
    name = "test_download_pkgs",
    base = "//ubuntu:ubuntu_16_0_4_vanilla",
    packages = [
        "curl",
        "netbase",
    ],
)

rule_test(
    name = "test_tar_name",
    generates = ["test_download_pkgs"],
    rule = "test_download_pkgs",
)
