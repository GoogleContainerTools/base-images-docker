FROM debian:jessie

RUN apt-get update && \
	apt-get install -y debootstrap xz-utils

COPY mkimage.sh /
COPY mkimage/debootstrap /mkimage/

ENTRYPOINT ["/mkimage.sh"]
