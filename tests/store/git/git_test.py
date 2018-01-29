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

"""Tests for git store"""

from contextlib import contextmanager
import os
from shutil import rmtree
import subprocess
import tempfile
import unittest
from store.git.git import LocalGitStore

class GitStoreTest(unittest.TestCase):

  TEST_STORE = "test_store"
  TEST_KEY = "test_key"
  GIT_ROOT = "git_root"
  STATUS_FILE = ".status"

  def setUp(self):
    self.tmp_root = tempfile.mkdtemp(suffix="test_root_")
    self.git_root = os.path.join(self.tmp_root, GitStoreTest.GIT_ROOT)
    os.mkdir(self.git_root)
    self.store_location = GitStoreTest.TEST_STORE
    self.status_file = os.path.join(self.tmp_root, GitStoreTest.STATUS_FILE)

  def tearDown(self):
    rmtree(self.tmp_root)

  @contextmanager
  def helper_test(self, suppress_error=True):
    with LocalGitStore(
       git_root = self.git_root,
       store_location = self.store_location,
       key = GitStoreTest.TEST_KEY,
       suppress_error = suppress_error,
       status_file = self.status_file) as git_store:
       yield git_store

  def _create_store(self, with_key=False):
    self.abs_store = os.path.join(self.git_root, self.store_location)
    os.mkdir(self.abs_store)
    if with_key:
      open(os.path.join(self.abs_store, GitStoreTest.TEST_KEY), "w").close()

  def _assert_exit_code(self, expected_exit_code):
    # Check if the status file has right exit code
    with open(self.status_file) as sf:
      exit_code = sf.readlines()[0]
      self.assertEquals(expected_exit_code, exit_code)

  def testGetIfKeyExists(self):
    self._create_store(with_key=True)
    with self.helper_test() as git_store:
      dest = os.path.join(self.tmp_root, "get_doc")
      git_store.get(dest)
    # Check if get document exists
    self.assertTrue(os.path.exists(dest))
    # Check if the status file has right exit code
    self._assert_exit_code('0')

  def testGetIfKeyNotExistsWithSuppress(self):
    self._create_store()
    dest = os.path.join(self.tmp_root, "get_doc")
    with self.helper_test() as git_store:
      git_store.get(dest)
    # Make sure dest is not created
    self.assertFalse(os.path.exists(dest))
    # Check if the status file has error exit code
    self._assert_exit_code('1')

  def testGetIfKeyNotExists(self):
    with self.assertRaises(LocalGitStore.LocalGitStoreError) as e:
      self._create_store()
      with self.helper_test(suppress_error=False) as git_store:
        dest=os.path.join(self.tmp_root, "get_doc")
        git_store.get(dest)

  def testGetIfStoreNotExists(self):
    with self.assertRaises(LocalGitStore.LocalGitStoreError) as e:
      with self.helper_test(suppress_error=False) as git_store:
        dest=os.path.join(self.tmp_root, "get_doc")
        git_store.get(dest)

  def _create_src(self):
    (src_fp, src) = tempfile.mkstemp(dir=self.tmp_root)
    return src

  def testPutIfKeyNotExists(self):
    self._create_store()
    with self.helper_test() as git_store:
      src = self._create_src()
      git_store.put_if_not_exists(src)
    # Make sure key exists in the store
    self.assertTrue(os.path.exists(os.path.join(self.abs_store, GitStoreTest.TEST_KEY)))
    self._assert_exit_code('0')

  def testPutIfNotExistsWhenKeyExists(self):
    abs_store = self._create_store(with_key=True)
    key_file = os.path.join(self.abs_store, GitStoreTest.TEST_KEY)
    m_time = os.path.getmtime(key_file)
    with self.helper_test(suppress_error=False) as git_store:
      src = self._create_src()
      git_store.put_if_not_exists(src)
    self.assertEquals(m_time, os.path.getmtime(key_file))
    self._assert_exit_code('0')


if __name__ == '__main__':
    unittest.main()
