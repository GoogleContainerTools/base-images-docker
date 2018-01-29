package(default_visibility = ["//visibility:public"])

load(
    "@bazel_tools//tools/build_rules:test_rules.bzl",
    "rule_test",
    "file_test",
)
load("//package_managers:download_pkgs.bzl", "download_pkgs")
load("//package_managers:install_pkgs.bzl", "install_pkgs")
load("//package_managers:apt_key.bzl", "add_apt_key")
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")
load("//package_managers:bootstrap_image.bzl", "bootstrap_image_macro")

download_pkgs(
    name = "test_download_pkgs",
    image_tar = "//ubuntu:ubuntu_16_0_4_vanilla.tar",
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
    installables_tar = ":test_download_pkgs.tar",
    output_image_name = "test_install_pkgs",
)

rule_test(
    name = "test_install_pkgs_rule",
    generates = [
        "test_install_pkgs.tar",
    ],
    rule = "test_install_pkgs",
)

add_apt_key(
    name = "gpg_image",
    image = "//debian/reproducible:debian9",
    keys = [
        "@bazel_gpg//file",
        "@launchpad_openjdk_gpg//file",
    ],
)

container_test(
    name = "gpg_test",
    configs = [":gpg_test.yaml"],
    image = ":gpg_image",
)

bootstrap_image_macro(
    name = "bootstrap_ubuntu",
    date = "2017/12/15",
    image_tar = "//ubuntu:ubuntu_16_0_4_vanilla.tar",
    output_image_name = "ubuntu",
    packages = [
        "curl",
        "netbase",
    ],
    store_location = "ubuntu/builds",
)

rule_test(
    name = "test_bootstrap_ubuntu",
    generates = [
        "bootstrap_ubuntu.tar",
    ],
    rule = "bootstrap_ubuntu",
)
