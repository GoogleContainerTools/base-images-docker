package(default_visibility = ["//visibility:public"])

load("@runtimes_common//structure_tests:tests.bzl", "structure_test")

exports_files(glob(["*.yaml"]))

DEBIAN_MAP = {
    8: "jessie",
    9: "stretch",
}

[structure_test(
    name = "debian%s_test" % num,
    config = ":debian_test.yaml",
    image = ":debian%s" % num,
) for num, distro in DEBIAN_MAP.items()]

[structure_test(
    name = "debian%s_version_test" % num,
    config = ":debian_%s_test.yaml" % num,
    image = ":debian%s" % num,
) for num, distro in DEBIAN_MAP.items()]

