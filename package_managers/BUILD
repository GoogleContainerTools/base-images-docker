package(default_visibility = ["//visibility:public"])

load("//package_managers:install_pkgs.bzl", "install_pkgs")

install_pkgs(
    name = "install_pkgs",
    image_tar = "//ubuntu:ubuntu_16_0_4_vanilla.tar",
    installables_tar = ":test_download_pkgs.tar",
    output_image_name = "test_ubuntu",
)
