FROM debian:jessie

RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y debootstrap
RUN apt-get install -y xz-utils

ENV WORKDIR /var/builder
WORKDIR ${WORKDIR}

ARG DOCKER_VERSION=1.11.2
RUN curl -sSLO https://github.com/docker/docker/archive/v${DOCKER_VERSION}.tar.gz
RUN tar -xzf v${DOCKER_VERSION}.tar.gz

ENV ENTRY_PATH=${WORKDIR}/docker-${DOCKER_VERSION}
RUN echo ${ENTRY_PATH}

ENTRYPOINT exec ${ENTRY_PATH}/contrib/mkimage.sh
