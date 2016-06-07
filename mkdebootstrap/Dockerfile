FROM debian:jessie

RUN apt-get update && \
    apt-get install -y curl debootstrap bzip2 && \
    apt-get clean

ENV WORKDIR /var/builder
WORKDIR ${WORKDIR}

ARG DOCKER_VERSION=1.11.2
RUN curl -sSLO https://github.com/docker/docker/archive/v${DOCKER_VERSION}.tar.gz && \
    tar -xzf v${DOCKER_VERSION}.tar.gz && \
    rm v${DOCKER_VERSION}.tar.gz

ENV WORKDIR ${WORKDIR}/docker-${DOCKER_VERSION}
WORKDIR ${WORKDIR}

ENTRYPOINT ["contrib/mkimage.sh"]
