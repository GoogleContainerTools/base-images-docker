Debian 8 and Debian 9 Images
=============

Source for the Google-maintained Debian container images.
These [docker](https://docker.io) images bundle the stable
[debian](https://www.debian.org) distribution suites,
with a few essential packages installed. Debian 9 (Stretch) is actively supported.

This image are available at `launcher.gcr.io/google/debian9`
and `gcr.io/google-appengine/debian9`.

The image is built using docker's
[`mkimage.sh`](https://github.com/docker/docker/blob/master/contrib/mkimage.sh).

## Usage

To use this image in your application, create a Dockerfile that
starts with this FROM line:

```
FROM launcher.gcr.io/google/debian9:latest
```










## Reproducible Debian Builds

This directory contains code and scripts for building reproducible
Debian base images.

The same git revision will result in a Docker image with the same digest,
every time.

### Usage

Use `gcloud container builds submit --config=debian/reproducible/cloudbuild.yaml .`
to build the image in the cloud.
To build locally, use: `bazel build //debian/reproducible:debian9`.
To run tests locally, use: `bazel test //debian/reproducible:debian9_test`.


### Process

We use a custom bazel rule to run debootstrap in a docker container.
Debootstrap must run in a container because it is incompatible with
the bazel sandbox.
This rule outputs a rootfs tarball, which can then be inserted into a
tarball with the `docker_build` rule.

#### Debootstrap

The first step is to generate a debian rootfs using debootstrap.
We use the debian snapshot mirror system to ensure the same debian
packages are used each build.
The SNAPSHOT file contains the name of the snapshot to use.
See the `mkimage.sh` script for this portion of the process.

#### Updates

To update the debian package versions used in the build,
modify the `DEB_SNAPSHOT` variable in the top-level `WORKSPACE` file
(along with its accompanying SHA256 checksum),
as well as in the `BUILD` file in this directory.
