debian-docker-image
===================

Source for [`google/debian`](https://index.docker.io/u/google/debian/):
a [docker](https://docker.io) image bundling the stable [debian](https://www.debian.org) distribution suite

The image is built using a copy of [mkimage-debootstrap.sh](https://raw.githubusercontent.com/dotcloud/docker/master/contrib/mkimage-debootstrap.sh) from [docker contrib](https://github.com/dotcloud/docker/tree/master/contrib).

## Usage

```
FROM google/debian:wheezy
```


## Build

```
make update-mkimage # optional, review changes to mkimage-debootstrap
make
```
