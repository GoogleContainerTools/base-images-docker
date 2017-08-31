## Reproducible Debian Builds

This directory contains code and scripts for building reproducible Debian base images.

The same git revision should result in a Docker image with the same digest, every time.

### Usage

Use `gcloud container builds submit --config=reproducible/cloudbuild.yaml .` to build the image in the cloud.
To build locally, use: `bazel build //reproducible:debian8`.
To run tests locally, use: `bazel test //reproducible:debian8_test`.


### Process

We use a custom bazel rule to run debootstrap in a docker container.
Debootstrap must run in a container because it is incompatible with the bazel sandbox.
This rule outputs a rootfs tarball, which can then be inserted into a tarball with the `docker_build` rule.

#### Debootstrap

The first step is to generate a debian rootfs using debootstrap.
We use the debian snapshot mirror system to ensure the same debian packages are used each build.
The SNAPSHOT file contains the name of the snapshot to use.
See the `mkimage.sh` script for this portion of the process.

#### Updates

To update the debian package versions used in the build, modify the `SNAPSHOT` variable in the `BUILD` file in this directory.
