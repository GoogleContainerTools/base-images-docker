PWD := $(shell pwd)
.PHONY: test
test:
	./check-fmt.sh
	bazel build //... --action_env=GIT_ROOT=$(PWD) --sandbox_writable_path=$(PWD)
	bazel test --test_output=errors //... --action_env=GIT_ROOT=$(PWD) --sandbox_writable_path=$(PWD)
	# Check for issues with the format of our bazel config files.
	buildifier -mode=check $(shell find . -name BUILD -type f)
	buildifier -mode=check $(shell find . -name WORKSPACE -type f)
	buildifier -mode=check $(shell find . -name '*.bzl' -type f)

complex-test:
	tests/package_managers/test_complex_packages.sh
	tests/package_managers/test_bootstrap_image_macro.sh
