## CentOS

This directory contains scripts and Dockerfiles for building a CentOS container image.

### Overview

We bootstrap the image following a process based on a combination of https://wiki.centos.org/HowTos/ManualInstall
and https://github.com/CentOS/sig-cloud-instance-build/blob/master/docker/centos-7.ks.

We avoid using kickstart to make it easier to run in a container environment like Cloud Build, but still reuse the
package list and cleanup steps from the kickstart installation.

To build an image:

```shell
gcloud builds submit --config=cloudbuild.yaml
```

To build locally:

```shell
docker build . -f Dockerfile.build -t builder

docker run --privileged -v $(pwd):/workspace builder /build.sh

docker build . -t mycentosimage
```
