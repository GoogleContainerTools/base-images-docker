PWD := $(shell pwd)
.PHONY: test
test:
	./check-fmt.sh
	bazel version
	bazel build //... --deleted_packages=ubuntu1604,ubuntu1804 --action_env=GIT_ROOT=$(PWD) --sandbox_writable_path=$(PWD) --verbose_failures --incompatible_bzl_disallow_load_after_statement=false
	bazel test -s --test_output=all //... --deleted_packages=ubuntu1604,ubuntu1804 --action_env=GIT_ROOT=$(PWD) --sandbox_writable_path=$(PWD) --verbose_failures --incompatible_bzl_disallow_load_after_statement=false

complex-test:
	tests/package_managers/test_complex_packages.sh
	tests/package_managers/test_bootstrap_image_macro.sh
