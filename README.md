debian-docker-image
======================

Source for [`google/debian`](https://index.docker.io/u/google/debian/):
a collection of [docker](https://docker.io) images bundling debian distributions.

Currently based on the [official debian docker images](https://index.docker.io/_/debian/) from the [stackbrew](https://github.com/dotcloud/stackbrew/blob/master/library/debian) library.

## Usage

    FROM google/debian:wheezy

    FROM google/debian:jessie

    FROM google/debian:sid
