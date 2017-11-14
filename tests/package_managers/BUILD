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
    name = "test_download_pkgs_rule",
    generates = [
        "test_download_pkgs",
    ],
    rule = "test_download_pkgs",
)

file_test(
    name = "test_download_pkgs_docker_run",
    file = ":test_download_pkgs",
    regexp = ".*docker run -d --privileged bazel/tests/package_managers:test_download_pkgs_build /bin/bash.*",
)

file_test(
    name = "test_download_pkgs_docker_cp",
    file = ":test_download_pkgs",
    regexp = ".*docker cp .*:test_download_pkgs_packages.tar tests/package_managers/test_download_pkgs.tar.*",
)

sh_test(
    name = "download_pkgs_run_test",
    srcs = ["download_pkgs_run_test.sh"],
    data = [":test_download_pkgs"],
)
