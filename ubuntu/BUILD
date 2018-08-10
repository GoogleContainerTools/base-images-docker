package(default_visibility = ["//visibility:public"])

load("//dockerfile_build:dockerfile_build.bzl", "dockerfile_build")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")
load("//package_managers:bootstrap_image.bzl", "bootstrap_image_macro")

UBUNTU_VERSIONS = [
    "16_0_4",
    "18_0_4",
]

UBUNTU_ENV = {
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    "DEBIAN_FRONTEND": "noninteractive",
}

# 'ubuntu_16_0_4' is a ubuntu_%s rootfs w/ ca-certificates, curl, and netbase
dockerfile_build(
    name = "ubuntu_16_0_4",
    base = ":ubuntu_16_0_4_vanilla",
    dockerfile = ":Dockerfile.ubuntu",
)

# The overlay directory contains files that should be overlaid into the rootfs at /.
pkg_tar(
    name = "overlay",
    srcs = glob(["overlay/**/*"]),
    package_dir = "/",
    strip_prefix = "overlay/",
)

# A handful of files need to be deleted from the base ubuntu image so that when our
# config stripper deletes those files from our reproducible images there won't be
# whiteout files.
# tar --delete deletes files in place so we need to uncompress to a temp tar
# then delete then output.
genrule(
    name = "ubuntu_16_0_4_vanilla_reproducible",
    srcs = ["@ubuntu_16_0_4_tar_download//file"],
    outs = ["ubuntu_16_0_4_vanilla_reproducible.tar"],
    cmd = "cp $< temp.tar.gz && gunzip temp.tar.gz && tar --delete var/log/dpkg.log var/cache/ldconfig/aux-cache -f temp.tar && mv temp.tar $@",
)

# There's a slightly different list of files to clean in 18_0_4.
genrule(
    name = "ubuntu_18_0_4_vanilla_reproducible",
    srcs = ["@ubuntu_18_0_4_tar_download//file"],
    outs = ["ubuntu_18_0_4_vanilla_reproducible.tar"],
    cmd = "cp $< temp.tar.gz && gunzip temp.tar.gz && tar --delete var/log/dpkg.log var/cache/ldconfig/aux-cache -f temp.tar && mv temp.tar $@",
)

# 'ubuntu_%s_vanilla' is docker image derived from a snapshot ubuntu_%s rootfs
[docker_build(
    name = "ubuntu_%s_vanilla" % version,
    env = UBUNTU_ENV,
    tars = [":ubuntu_%s_vanilla_reproducible" % version],
) for version in UBUNTU_VERSIONS]

[bootstrap_image_macro(
    name = "bootstrap_ubuntu_%s" % version,
    date = "20180810",
    image_tar = ":ubuntu_%s_vanilla.tar" % version,
    output_image_name = "ubuntu_%s" % version,
    packages = [
        "ca-certificates",
        "curl",
        "libc-bin",
        "netbase",
    ],
    store_location = "ubuntu/%s/builds" % version,
) for version in UBUNTU_VERSIONS]
