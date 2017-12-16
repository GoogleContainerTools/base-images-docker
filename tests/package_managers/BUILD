package(default_visibility = ["//visibility:public"])

load(
    "@bazel_tools//tools/build_rules:test_rules.bzl",
    "rule_test",
    "file_test",
)
load("//package_managers:download_pkgs.bzl", "download_pkgs")
load("//package_managers/apt_get:apt_get.bzl", "generate_apt_get")

download_pkgs(
    name = "test_download_pkgs",
    image_tar = "//ubuntu:ubuntu_16_0_4_vanilla.tar",
    package_manager_generator = "//package_managers/apt_get:default_docker_packages",
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
    regexp = ".*docker cp .*:default_docker_packages.tar tests/package_managers/test_download_pkgs.tar.*",
)

sh_test(
    name = "download_pkgs_run_test",
    srcs = ["download_pkgs_run_test.sh"],
    data = [":test_download_pkgs"],
)

load("//package_managers:install_pkgs.bzl", "install_pkgs")

generate_apt_get(
    name = "apt_get_from_tar",
    tar = ":test_download_pkgs.tar",
)

install_pkgs(
    name = "test_install_pkgs",
    image_tar = "//ubuntu:ubuntu_16_0_4_vanilla.tar",
    output_image_name = "test_install_pkgs",
    package_manager_generator = ":apt_get_from_tar",
)

rule_test(
    name = "test_install_pkgs_rule",
    generates = [
        "test_install_pkgs.tar",
    ],
    rule = "test_install_pkgs",
)

