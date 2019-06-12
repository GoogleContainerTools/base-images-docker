load(
    "@bazel_tools//tools/build_rules:test_rules.bzl",
    "file_test",
    "rule_test",
)
load("//package_managers:download_pkgs.bzl", "download_pkgs")

package(default_visibility = ["//visibility:public"])

download_pkgs(
    name = "test_download_pkgs_at_root",
    image_tar = "//ubuntu:ubuntu_16_0_4_vanilla.tar",
    packages = [
        "curl",
        "netbase",
    ],
)

rule_test(
    name = "test_download_pkgs_at_root_rule",
    generates = [
        "test_download_pkgs_at_root",
    ],
    rule = "test_download_pkgs_at_root",
)

file_test(
    name = "test_download_pkgs_at_root_docker_run",
    file = ":test_download_pkgs_at_root",
    regexp = "image_id.* ubuntu/ubuntu_16_0_4_vanilla.tar)$",
)

file_test(
    name = "test_download_pkgs_at_root_docker_cp",
    file = ":test_download_pkgs_at_root",
    regexp = ".*docker cp .*:test_download_pkgs_at_root_packages.tar test_download_pkgs_at_root.tar.*",
)

file_test(
    name = "test_download_pkgs_at_root_metadata_csv",
    file = ":test_download_pkgs_at_root_metadata.csv",
    regexp = "curl",
)

sh_test(
    name = "download_pkgs_at_root_run_test",
    srcs = [":download_pkgs_at_root_run_test.sh"],
    data = [":test_download_pkgs_at_root.tar"],
)
