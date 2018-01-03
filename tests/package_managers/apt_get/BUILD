package(default_visibility = ["//visibility:public"])

load("//package_managers/apt_get:repos.bzl", "generate_additional_repos")
load(
    "@bazel_tools//tools/build_rules:test_rules.bzl",
    "rule_test",
    "file_test",
)

generate_additional_repos(
    name = "test_repos",
    repos = [
        "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8",
        "deb [arch=amd64] http://myrepo.com/foo unstable test",
    ],
)

sh_test(
    name = "assert_repos_created",
    srcs = ["assert_repos_created.sh"],
    data = [":test_repos.tar"],
)

rule_test(
    name = "assert_generate_additional_repos",
    generates = [
        "test_repos.tar",
    ],
    rule = "test_repos",
)
