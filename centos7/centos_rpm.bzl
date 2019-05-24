# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Repository rule for pulling a Centos release rpm.

Note this rule is very specific to download Centos release rpm and is not meant
to be used to download other files.
"""

_DOWNLOADED_FILE_NAME = "centos.rpm"
_BASE_URL = "http://mirror.centos.org/centos/{}/os/x86_64/Packages/"
_REGEX = ".*centos-release.*rpm"
_BUILD = """
package(default_visibility = ["//visibility:public"])
filegroup(
    name = "file",
    srcs = ["{}"],
)
"""

def _centos_rpm_impl(repository_ctx):
    """Implementation of the centos_rpm rule."""
    download_path = repository_ctx.path("file/" + _DOWNLOADED_FILE_NAME)

    download_command = [
        "wget",
        "-q",
        _BASE_URL.format(repository_ctx.attr.version),
        "-np",  # Do not ascend to the parent directory when retrieving recursively.
        "-nd",  # Do not create a hierarchy of directories when retrieving recursively.
        "-r",  # Recursive
        "-R",  # Avoid downloading auto-generated index.html files.
        "*index.html*",
        "--accept-regex",  # Passing the file regex.
        _BASE_URL.format(repository_ctx.attr.version) + _REGEX,
    ]

    download_result = repository_ctx.execute(download_command, working_directory = "file")
    if download_result.return_code:
        fail("Download command failed: {} ({})".format(
            download_result.stderr,
            " ".join(download_command),
        ))

    # Make sure we only downloaded 1 file.
    count_command = ["sh", "-c", "ls -1 | wc -l"]
    count_result = repository_ctx.execute(count_command, working_directory = "file")
    if count_result.return_code:
        fail("Count command failed: {} ({})".format(
            count_result.stderr,
            " ".join(count_command),
        ))
    if count_result.stdout.strip("\n") != "1":
        fail(
            "{} files downloaded. Make sure the regex only matches to exactly 1 file."
                .format(count_result.stdout.strip("\n")),
        )

    # Rename the downloaded file.
    rename_command = ["sh", "-c", "mv $(ls) {}".format(download_path)]
    rename_result = repository_ctx.execute(rename_command, working_directory = "file")
    if rename_result.return_code:
        fail("Rename command failed: {} ({})".format(
            rename_result.stderr,
            " ".join(rename_command),
        ))

    # Add a top-level BUILD file to export all the downloaded files.
    repository_ctx.file("file/BUILD", _BUILD.format(_DOWNLOADED_FILE_NAME))

centos_rpm = repository_rule(
    attrs = {
        "version": attr.int(
            mandatory = True,
            doc = "The major version of Centos",
        ),
    },
    implementation = _centos_rpm_impl,
)
