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
    packages = [
#        "foo",
#        "test",
        "curl"
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
    content = """#!/bin/bash
set -x
apt-get update -y && mkdir -p /tmp/install/./partial && apt-get install --no-install-recommends -y -q -o Dir::Cache=\"/tmp/install\" -o Dir::Cache::archives=\".\" foo test --download-only && tar -cpf test_apt_get.tar --directory /tmp/install/. `cd /tmp/install/. && ls *.deb`
tar -xvf test_apt_get.tar && dpkg -i ./*.deb && apt-get install -f""",
    file = ":test_apt_get",
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

generate_apt_get(
    name = "test_apt_get_from_tar",
    tar = "//tests/package_managers:test_download_pkgs.tar",
)

rule_test(
    name = "assert_generate_apt_get_from_tar",
    generates = [
        "test_apt_get_from_tar",
    ],
    rule = "test_apt_get_from_tar",
)

file_test(
    name = "test_install_from_tar_script",
    content = """#!/bin/bash
set -x

tar -xvf tests/package_managers/test_download_pkgs.tar && dpkg -i ./*.deb && apt-get install -f""",
    file = ":test_apt_get_from_tar",
)
