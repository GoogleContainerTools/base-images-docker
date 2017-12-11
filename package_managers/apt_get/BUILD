package(default_visibility = ["//visibility:public"])

load("//package_managers/apt_get:apt_get.bzl", "generate_apt_get")

generate_apt_get(
    name = "default_docker_packages",
    download_only = True,
    packages = [
        "ca-certificates",
        "curl",
        "netbase",
    ],
)
