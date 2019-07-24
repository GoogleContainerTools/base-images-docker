PWD := $(shell pwd)

CONTAINER_TEST_TARGETS = :image-test :file_update_test :dependency_update_test
BAZEL_TEST_OPTS = --test_output=errors --strategy=TestRunner=standalone

.PHONY: test
test:
	./check-fmt.sh
	bazel version
	bazel build //... --action_env=GIT_ROOT=$(PWD) --sandbox_writable_path=$(PWD) --verbose_failures --incompatible_bzl_disallow_load_after_statement=false
	bazel test --test_output=errors //... --action_env=GIT_ROOT=$(PWD) --sandbox_writable_path=$(PWD) --verbose_failures --incompatible_bzl_disallow_load_after_statement=false
	cd ubuntu1604 && bazel test $(BAZEL_TEST_OPTS) $(CONTAINER_TEST_TARGETS) && cd ..
	cd ubuntu1804 && bazel test $(BAZEL_TEST_OPTS) $(CONTAINER_TEST_TARGETS) && cd ..
	cd debian9 && bazel test $(BAZEL_TEST_OPTS) $(CONTAINER_TEST_TARGETS) && cd ..
	cd centos7 && bazel test $(BAZEL_TEST_OPTS) $(CONTAINER_TEST_TARGETS) && cd ..

complex-test:
	tests/package_managers/test_bootstrap_image_macro.sh
