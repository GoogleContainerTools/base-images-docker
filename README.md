debian-docker
=============

Source for `l.gcr.io/google/debian8` and `gcr.io/google-appengine/debian8`:
a [docker](https://docker.io) image bundling the stable [debian](https://www.debian.org) distribution suite

The image is built using docker's [`mkimage.sh`](https://github.com/docker/docker/blob/master/contrib/mkimage.sh).

## Usage

```
FROM l.gcr.io/google/debian8:latest
```


## Build

`make all` will generate the builder image and create a fresh debootstrap rootfs
for the debian version specified by `DEBIAN_SUITE` (defaults to jessie). The
bzipped tarball which results is then used to create a bare debian docker image.

```
# Generate the jessie image
make all DEBIAN_SUITE=jessie
