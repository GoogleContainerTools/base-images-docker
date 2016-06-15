FROM scratch
ENV DEBIAN_FRONTEND noninteractive
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ARG DEBIAN_SUITE
ADD google-debian-${DEBIAN_SUITE}.tar.bz2 /
