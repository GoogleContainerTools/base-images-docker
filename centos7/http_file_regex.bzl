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

"""Repository rule for pulling a file matching certain regex from a base URL.
"""

_DEFAULT_FILE_NAME = "downloaded"

_BUILD = """
package(default_visibility = ["//visibility:public"])
filegroup(
    name = "file",
    srcs = ["{}"],
)
"""

def _http_file_regex_impl(repository_ctx):
    """Implementation of the gcs_file rule."""
    repo_root = repository_ctx.path(".")
    forbidden_files = [
        repo_root,
        repository_ctx.path("WORKSPACE"),
        repository_ctx.path("BUILD"),
        repository_ctx.path("BUILD.bazel"),
        repository_ctx.path("file/BUILD"),
        repository_ctx.path("file/BUILD.bazel"),
    ]
    downloaded_file_path = repository_ctx.attr.downloaded_file_path or _DEFAULT_FILE_NAME
    download_path = repository_ctx.path("file/" + downloaded_file_path)
    if download_path in forbidden_files or not str(download_path).startswith(str(repo_root)):
        fail("'%s' cannot be used as downloaded_file_path in http_file_regex" % repository_ctx.attr.downloaded_file_path)

    download_command = [
        "wget",
        "-q",
        repository_ctx.attr.url,
        "-np",  # Do not ascend to the parent directory when retrieving recursively.
        "-nd",  # Do not create a hierarchy of directories when retrieving recursively.
        "-r",  # Recursive
        "-R",  # Avoid downloading auto-generated index.html files.
        "*index.html*",
        "--accept-regex",  # Passing the file regex.
        repository_ctx.attr.url + repository_ctx.attr.regex,
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
    repository_ctx.file("file/BUILD", _BUILD.format(downloaded_file_path))

http_file_regex = repository_rule(
    attrs = {
        "downloaded_file_path": attr.string(
            doc = ("Path assigned to the file downloaded. Default to `downloaded"),
        ),
        "regex": attr.string(
            mandatory = True,
            doc = ("The regex of file to download. It should be the part " +
                   "to be appended to the url."),
        ),
        "url": attr.string(
            mandatory = True,
            doc = "The base/root url of the file. Regex is not allowed in the url.",
        ),
    },
    implementation = _http_file_regex_impl,
)
