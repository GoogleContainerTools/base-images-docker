package(default_visibility = ["//visibility:public"])

load("//package_managers:download_pkgs.bzl", "download_pkgs")
load(
    "@bazel_tools//tools/build_rules:test_rules.bzl",
    "rule_test",
    "file_test",
)
load("//package_managers/apt_get:apt_get.bzl", "generate_apt_get")

download_pkgs(
    name = "test_download_pkgs",
    package_manager_script = generate_apt_get(
        name = "one",
        archive_dir = ".",
        cache_dir = "install",
        download_only = True,
        packages = [
            "curl",
            "netbase",
        ],
    ),
)

rule_test(
    name = "test_tar_name",
    generates = ["test_download_pkgs.tar"],
    rule = "test_download_pkgs",
)
