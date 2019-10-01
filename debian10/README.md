This is a Debian 10 container.

## Reproducible Debian Builds

This directory contains code and scripts for building reproducible
Debian base images.

The same git revision will result in a Docker image with the same digest,
every time.

### Usage

Use `gcloud builds submit --config=cloudbuild.yaml`
to build the image in the cloud.
To build locally, use: `bazel run :image`.
To run tests locally, use: `bazel test :image-test`.

### Process

We use debootstrap in a docker container to generate a debian rootfs tarball.
See the `mkimage.sh` script for this portion of the process. This tarball can
then be inserted into a tarball with the `container_image` rule.

We archive the generated rootfs tarballs in a GCS bucket and use them in
container releases to ensure containers are reproducible.
