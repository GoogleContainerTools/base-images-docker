## Reproducible Debian Builds

This directory contains code and scripts for building reproducible Debian base images.

The same git revision should result in a Docker image with the same digest, every time.


### Usage

Use `bazel build //repeatable:debian8` to generate the image locally, or `gcloud container builds submit --config=repeatable/cloudbuild.yaml .` to build it in the cloud.

### Process

This build process is designed to run in Google Cloud Container Builder.
The overall build pipeline is defined in the cloudbuild.yaml file, in this directory.

Reproducibility is achieved via a combination of Bazel and a custom debootstrap script.

#### Debootstrap

The first step is to generate a debian rootfs using debootstrap.
We use the debian snapshot mirror system to ensure the same debian packages are used each build.
The SNAPSHOT file contains the name of the snapshot to use.
See the `mkimage.sh` script for this portion of the process.

#### Bazel

We use bazel to generate the rootfs tarball, and insert it into a Docker image that is pushed to a registry.
Unfortunately using a simple Dockerfile like this one:

```
FROM scratch
ADD rootfs.tar.gz
```

will result in an image with a different digest each time the build is executed, even if the tarball is the same.

See the `BUILD` file for the bazel workflow.
