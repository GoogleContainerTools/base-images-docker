# How to build these base images

We use `bazel` to build most of the images in this repository, so that we can build them reproducibly.
To learn about how we generate reproducible images, see [the design doc](./reproducible/README.md).

To build all images, use:

```shell
bazel build //...
```

This can be slow the first time, but future builds are incremental and very fast.

Tests are implemented using the [structure_test](https://www.github.com/GoogleCloudPlatform/runtimes-common/structure_test) library.
The tests are defined as YAML files in the `tests` directory.

To run tests, use:

```shell
bazel test //...
```

We also have a set of formatting and style tests, which should be run before sending PRs.
To run these, use:

```shell
make test
```

# How to become a contributor and submit your own code

## Contributor License Agreements

We'd love to accept your patches! Before we can take them, we have to jump a couple of legal hurdles.

Please fill out either the individual or corporate Contributor License Agreement (CLA).

  * If you are an individual writing original source code and you're sure you own the intellectual property, then you'll need to sign an [individual CLA](http://code.google.com/legal/individual-cla-v1.0.html).
  * If you work for a company that wants to allow you to contribute your work, then you'll need to sign a [corporate CLA](http://code.google.com/legal/corporate-cla-v1.0.html).

Follow either of the two links above to access the appropriate CLA and instructions for how to sign and return it. Once we receive it, we'll be able to accept your pull requests.

## Contributing A Patch

1. Submit an issue describing your proposed change to the repo in question.
1. The repo owner will respond to your issue promptly.
1. If your proposed change is accepted, and you haven't already done so, sign a Contributor License Agreement (see details above).
1. Fork the desired repo, develop and test your code changes.
1. Submit a pull request.
