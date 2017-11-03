package(default_visibility = ["//visibility:public"])

load("//dockerfile_build:dockerfile_build.bzl", "dockerfile_build")

UBUNTU_VERSIONS = [
    "16_0_4",
]

[dockerfile_build(
    name = "ubuntu_%s" % version,
    base = "//ubuntu/reproducible:ubuntu_%s_vanilla" % version,
    dockerfile = ":Dockerfile.ubuntu",
) for version in UBUNTU_VERSIONS]

[dockerfile_build(
    name = "ubuntu_%s_build" % version,
    base = "//ubuntu/reproducible:ubuntu_%s" % version,
    dockerfile = ":Dockerfile.ubuntu_build",
) for version in UBUNTU_VERSIONS]
