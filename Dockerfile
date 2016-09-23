FROM scratch
ENV DEBIAN_FRONTEND noninteractive
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV PORT 8080
ADD rootfs.tar.xz /
RUN apt-get -q update && \
    apt-get install --no-install-recommends -y -q ca-certificates && \
    apt-get -y -q upgrade && \
    rm /var/lib/apt/lists/*_*
