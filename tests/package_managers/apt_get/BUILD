package(default_visibility = ["//visibility:public"])

load("//package_managers/apt_get:apt_get.bzl", "generate_apt_get")
load("//package_managers/apt_get:repos.bzl", "generate_additional_repos")
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
    content = "#!/bin/bash\nset -ex\napt-get update -y && mkdir -p /install/./partial && apt-get install --no-install-recommends -y -q -o Dir::Cache=\"/install\" -o Dir::Cache::archives=\".\" foo test --download-only && tar -cpf test_apt_get.tar --directory /install/. `cd /install/. && ls *.deb`",
    file = ":test_apt_get",
)

generate_additional_repos(
    name = "test_repos",
    repos = [
        "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8",
        "deb [arch=amd64] http://myrepo.com/foo unstable test",
    ],
)

genrule(
    name = "expand_test_repos",
    srcs = [":test_repos.tar"],
    outs = ["test_repo_contents.txt"],
    cmd = "tar -tf $(<) > $(@)",
)

rule_test(
    name = "assert_generate_additional_repos",
    generates = [
        "test_repos.tar",
    ],
    rule = "test_repos",
)

file_test(
    name = "assert_repo_one_created",
    file = ":test_repo_contents.txt",
    regexp = "./etc/apt/sources.list.d/test_repos_0.list",
)

file_test(
    name = "assert_repo_two_created",
    file = ":test_repo_contents.txt",
    regexp = "./etc/apt/sources.list.d/test_repos_1.list",
)
