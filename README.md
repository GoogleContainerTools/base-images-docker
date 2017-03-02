debian-docker
=============

Source for `gcr.io/google_appengine/debian`:
a [docker](https://docker.io) image bundling the stable [debian](https://www.debian.org) distribution suite

The image is built using docker's [`mkimage.sh`](https://github.com/docker/docker/blob/master/contrib/mkimage.sh).

For details on how to contribute to this image, see our [contribution guidelines](CONTRIB.md).

## Usage

To use this image in your application, create a Dockerfile that starts with this FROM line:

```
FROM gcr.io/google-appengine/debian8:latest
```

Then add in any necessary build steps to install packages and your code.
