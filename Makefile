PWD := $(shell pwd)
.PHONY: test
test:
	./check-fmt.sh
	bazel version
	bazel build //... --deleted_packages=ubuntu1604,ubuntu1804 --action_env=GIT_ROOT=$(PWD) --sandbox_writable_path=$(PWD) --incompatible_remove_native_http_archive=false
	bazel test --test_output=errors //... --deleted_packages=ubuntu1604,ubuntu1804 --action_env=GIT_ROOT=$(PWD) --sandbox_writable_path=$(PWD) --incompatible_remove_native_http_archive=false

complex-test:
	tests/package_managers/test_complex_packages.sh
	tests/package_managers/test_bootstrap_image_macro.sh
