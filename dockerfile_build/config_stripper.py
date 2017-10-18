#!/usr/bin/python

# Copyright 2017 Google Inc. All rights reserved.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import argparse
import json
import os
import shutil
import sys
import tarfile
import tempfile

_TIMESTAMP = '1970-01-01T00:00:00Z'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--in_tar_path', type=str,
                        help='Path to docker save tarball',
                        required=True)
    parser.add_argument('--out_tar_path', type=str,
                        help='Path to output stripped tarball',
                        required=True)
    args = parser.parse_args()

    return strip_tar(args.in_tar_path, args.out_tar_path)


def strip_tar(input, output):
    # Unpack the tarball, modify configs in place, and rearchive.
    # We need to take care to keep the files sorted.

    tempdir = tempfile.mkdtemp()
    with tarfile.open(name=input, mode='r') as it:
        it.extractall(tempdir)
    
    with open(os.path.join(tempdir, 'manifest.json'), 'r') as mf:
        manifest = json.load(mf)
    for image in manifest:
        config = image['Config']
        strip_config(os.path.join(tempdir, config))

    # Collect the files before adding, so we can sort them.
    files_to_add = []
    for root, _, files in os.walk(tempdir):
        for f in files:
            name = os.path.join(root, f)
            files_to_add.append(name)

    with tarfile.open(name=output, mode='w') as ot:
        for f in sorted(files_to_add):
            # Strip the tempdir path
            arcname = os.path.relpath(f, tempdir)
            ot.add(f, arcname)

    shutil.rmtree(tempdir)
    return 0

def strip_config(path):
    with open(path, 'r') as f:
        config = json.load(f)
    config['created'] = _TIMESTAMP
    for entry in config['history']:
        entry['created'] = _TIMESTAMP
    
    with open(path, 'w') as f:
        json.dump(config, f, sort_keys=True)

if __name__ == "__main__":
    sys.exit(main())
