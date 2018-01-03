.PHONY: test
test:
	./check-fmt.sh
	bazel build //...
	bazel test --test_output=errors //...
	test/packages/test_complex_packages.sh
	# Check for issues with the format of our bazel config files.
	buildifier -mode=check $(find . -name BUILD -type f)
	buildifier -mode=check $(find . -name WORKSPACE -type f)
	buildifier -mode=check $(find . -name '*.bzl' -type f)
