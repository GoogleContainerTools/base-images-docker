package(default_visibility = ["//visibility:public"])

load("//package_managers/apt_get:apt_get.bzl", "generate_apt_get")
load(
    "@bazel_tools//tools/build_rules:test_rules.bzl",
    "rule_test",
    "file_test",
)

generate_apt_get(
    name = "test_apt_get",
    download_only = True,
    packages = [
        "foo",
        "test",
    ],
)

rule_test(
    name = "assert_generate_apt_get",
    generates = [
        "test_apt_get",
    ],
    rule = "test_apt_get",
)

file_test(
    name = "test_script",
    content = ("apt-get update -y && apt-get install --no-install-recommends -y -q -o Dir::Cache=\"/var/cache/apt\" -o Dir::Cache::archives=\"archives\" foo test --download-only && tar -cf installables.tar /var/cache/apt/archives/*.deb"),
    file = ":test_apt_get",
)
