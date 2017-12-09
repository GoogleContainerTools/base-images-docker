package(default_visibility = ["//visibility:public"])

load("//package_managers/apt_get:apt_get.bzl", "generate_apt_get")
load("//package_managers/apt_get:repos.bzl", "generate_additional_repos")

generate_apt_get(
    name = "default_docker_packages",
    download_only = True,
    packages = [
        "ca-certificates",
        "curl",
        "netbase",
    ],
)

generate_additional_repos(
    name = "default_repos",
    repos = ["deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8"],
)
