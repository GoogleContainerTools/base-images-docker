PWD := $(shell pwd)
.PHONY: test
test:
	./check-fmt.sh
	bazel version
	bazel build //... --action_env=GIT_ROOT=$(PWD) --sandbox_writable_path=$(PWD) --incompatible_remove_native_http_archive=false
	bazel test --test_output=errors //... --action_env=GIT_ROOT=$(PWD) --sandbox_writable_path=$(PWD) --incompatible_remove_native_http_archive=false

complex-test:
	tests/package_managers/test_complex_packages.sh
	tests/package_managers/test_bootstrap_image_macro.sh
