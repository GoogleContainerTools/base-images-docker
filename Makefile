.PHONY: test
test:
	./check-fmt.sh
	bazel build //...
	bazel test --test_output=errors //...
	# Check for issues with the format of our bazel config files.
	buildifier -mode=check $(shell find . -name BUILD -type f)
	buildifier -mode=check $(shell find . -name WORKSPACE -type f)
	buildifier -mode=check $(shell find . -name '*.bzl' -type f)

complex-test:
	tests/package_managers/test_complex_packages.sh
