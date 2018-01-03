package(default_visibility = ["//visibility:public"])
load(
    "@bazel_tools//tools/build_rules:test_rules.bzl",
    "rule_test",
    "file_test",
)
load("//package_managers:download_pkgs.bzl", "download_pkgs")
load("//package_managers:install_pkgs.bzl", "install_pkgs")

download_pkgs(
    name = "test_download_pkgs",
    image_tar = "//ubuntu:ubuntu_16_0_4_vanilla.tar",
    packages = ["curl", "netbase"],
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
    regexp = ".*docker run -d --privileged bazel/tests/package_managers:test_download_pkgs_build sh -c $'.*",
)
file_test(
    name = "test_download_pkgs_docker_cp",
    file = ":test_download_pkgs",
    regexp = ".*docker cp .*:test_download_pkgs.tar tests/package_managers/test_download_pkgs.tar.*",
)
sh_test(
    name = "download_pkgs_run_test",
    srcs = ["download_pkgs_run_test.sh"],
    data = [":test_download_pkgs.tar"],
)

install_pkgs(
    name = "test_install_pkgs",
    image_tar = "//ubuntu:ubuntu_16_0_4_vanilla.tar",
    output_image_name = "test_install_pkgs",
    installables_tar = ":test_download_pkgs.tar"
)
rule_test(
    name = "test_install_pkgs_rule",
    generates = [
        "test_install_pkgs.tar",
    ],
    rule = "test_install_pkgs",
)
