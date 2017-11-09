package(default_visibility = ["//visibility:public"])

load("//package_managers:download_pkgs.bzl", "download_pkgs")
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
