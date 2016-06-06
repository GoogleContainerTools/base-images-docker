FROM debian:jessie

RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y debootstrap
RUN apt-get install -y bzip2

ENV WORKDIR /var/builder
WORKDIR ${WORKDIR}

ARG DOCKER_VERSION=1.11.2
RUN curl -sSLO https://github.com/docker/docker/archive/v${DOCKER_VERSION}.tar.gz
RUN tar -xzf v${DOCKER_VERSION}.tar.gz

ENV WORKDIR ${WORKDIR}/docker-${DOCKER_VERSION}
WORKDIR ${WORKDIR}

ENTRYPOINT ["contrib/mkimage.sh"]
