debian-docker
=============

Source for `gcr.io/google_appengine/debian`:
a [docker](https://docker.io) image bundling the stable [debian](https://www.debian.org) distribution suite

The image is built using docker's [`mkimage.sh`](https://github.com/docker/docker/blob/master/contrib/mkimage.sh).

## Usage

```
FROM gcr.io/google-appengine/debian8:latest 
```


## Build

`make all` will generate the builder image and create a fresh debootstrap rootfs
for the debian version specified by `DEBIAN_SUITE` (defaults to jessie). The
bzipped tarball which results is then used to create a bare debian docker image.

```
# Generate the jessie image
make all DEBIAN_SUITE=jessie
