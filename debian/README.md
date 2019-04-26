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
