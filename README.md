debian-docker-image
======================

Source for [`google/debian`](https://index.docker.io/u/google/debian/):
a collection of [docker](https://docker.io) images bundling [debian](https://www.debian.org) distribution suites.

Currently based on the [official debian docker images](https://index.docker.io/_/debian/) from the [stackbrew](https://github.com/dotcloud/stackbrew/blob/master/library/debian) library.

## Usage

### Stable

```
FROM google/debian:wheezy
```

### Testing

```
FROM google/debian:jessie
```

### Unstable

```
FROM google/debian:sid
```
