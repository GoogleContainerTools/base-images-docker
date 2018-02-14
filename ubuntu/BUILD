package(default_visibility = ["//visibility:public"])

load("//dockerfile_build:dockerfile_build.bzl", "dockerfile_build")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")
load("//package_managers:bootstrap_image.bzl", "bootstrap_image_macro")

UBUNTU_VERSIONS = [
    "16_0_4",
]

# 'ubuntu_%s' is a ubuntu_%s rootfs w/ ca-certificates, curl, and netbase
# This image is used for node images. Look node/reproducible/BUILD#L31
[dockerfile_build(
    name = "ubuntu_%s" % version,
    base = ":ubuntu_%s_vanilla" % version,
    dockerfile = ":Dockerfile.ubuntu",
) for version in UBUNTU_VERSIONS]

# 'ubuntu_%s_build' is the 'ubuntu_%s' image w/ build-essential and python2.7
#  This image is used for node images. Look node/reproducible/BUILD#L41
[dockerfile_build(
    name = "ubuntu_%s_build" % version,
    base = ":ubuntu_%s" % version,
    dockerfile = ":Dockerfile.ubuntu_build",
) for version in UBUNTU_VERSIONS]

UBUNTU_ENV = {
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

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
[genrule(
    name = "ubuntu_%s_vanilla_reproducible" % version,
    srcs = ["@ubuntu_%s_tar_download//file" % version],
    outs = ["ubuntu_%s_vanilla_reproducible.tar" % version],
    cmd = "cp $< temp.tar.gz && gunzip temp.tar.gz && tar --delete var/log/dpkg.log var/cache/apt/pkgcache.bin var/cache/ldconfig/aux-cache -f temp.tar && mv temp.tar $@",
) for version in UBUNTU_VERSIONS]

# 'ubuntu_%s_vanilla' is docker image derived from a snapshot ubuntu_%s rootfs
[docker_build(
    name = "ubuntu_%s_vanilla" % version,
    env = UBUNTU_ENV,
    tars = [":ubuntu_%s_vanilla_reproducible" % version],
) for version in UBUNTU_VERSIONS]

bootstrap_image_macro(
    name = "bootstrap_ubuntu",
    image_tar = ":ubuntu_16_0_4_vanilla.tar",
    packages = [
        "curl",
        "netbase",
        "ca-certificates",
    ],
    store_location = "ubuntu/builds",
    date = "20180214",
    output_image_name = "ubuntu_16_0_4",
)
