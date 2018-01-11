package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")

exports_files(glob(["*.yaml"]))

DEBIAN_MAP = {
    8: "jessie",
    9: "stretch",
}

[container_test(
    name = "debian%s_test" % num,
    configs = [":debian_test.yaml"],
    image = "//debian/reproducible:debian%s" % num,
) for num, distro in DEBIAN_MAP.items()]

[container_test(
    name = "debian%s_version_test" % num,
    configs = [":debian_%s_test.yaml" % num],
    image = "//debian/reproducible:debian%s" % num,
) for num, distro in DEBIAN_MAP.items()]
