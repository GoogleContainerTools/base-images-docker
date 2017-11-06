package(default_visibility = ["//visibility:public"])

load("//package_managers/apt_get:apt_get.bzl", "apt_get")

apt_get(
    name = "test_one_package",
    packages = ['foo', 'test'],
    download_only = True, 
)
