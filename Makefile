PWD := $(shell pwd)
.PHONY: test
test:
	./check-fmt.sh
	bazel version
	bazel build //... --deleted_packages=ubuntu1604,ubuntu1804 --action_env=GIT_ROOT=$(PWD) --sandbox_writable_path=$(PWD) --verbose_failures --incompatible_bzl_disallow_load_after_statement=false
	bazel test --test_output=errors //... --deleted_packages=ubuntu1604,ubuntu1804 --action_env=GIT_ROOT=$(PWD) --sandbox_writable_path=$(PWD) --verbose_failures --incompatible_bzl_disallow_load_after_statement=false
	cd ubuntu1604 && bazel test --test_output=errors :image-test && cd ..
	cd ubuntu1804 && bazel test --test_output=errors :image-test && cd ..

complex-test:
	tests/package_managers/test_complex_packages.sh
	tests/package_managers/test_bootstrap_image_macro.sh
