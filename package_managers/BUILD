package(default_visibility = ["//visibility:public"])

load("//package_managers:install_pkgs.bzl", "install_pkgs")
load("//package_managers:download_pkgs.bzl", "download_image_pkgs")

install_pkgs(
    name = "install_pkgs",
    image_tar = "//ubuntu:ubuntu_16_0_4_vanilla",
    installables_tar = "//tests/package_managers:test_download_pkgs",
    output_image_name = "test_ubuntu",
)
