debian-docker
=============

Source for the Google-maintained Debian container image: a [docker](https://docker.io) image bundling the stable [debian](https://www.debian.org) distribution suite.

This image is available at `launcher.gcr.io/google/debian8` and `gcr.io/google-appengine/debian8`.

The image is built using docker's [`mkimage.sh`](https://github.com/docker/docker/blob/master/contrib/mkimage.sh).

For details on how to contribute to this image, see our [contribution guidelines](CONTRIB.md).

## Usage

To use this image in your application, create a Dockerfile that starts with this FROM line:

```
FROM launcher.gcr.io/google/debian8:latest
```
