# Copyright 2017 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
Rule to compute the md5 checksum of a string.
"""

def md5(ctx, instr):
    out = ctx.new_file(instr + ".md5")
    ctx.action(
        executable = ctx.executable.md5,
        arguments = [instr, out.path],
        outputs = [out],
        mnemonic = "MD5"
    )
    return out


tools = {
    "md5": attr.label(
        default=Label("//util:md5"),
        cfg="host",
        executable=True,
        allow_files=True
    )
}
