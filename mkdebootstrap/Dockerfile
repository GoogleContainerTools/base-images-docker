FROM gcr.io/sharif-test/vanilla-debian:jessie

RUN apt-get update && \
	apt-get install -y debootstrap bzip2

COPY mkimage.sh /
COPY mkimage/debootstrap /mkimage/

ENTRYPOINT ["/mkimage.sh"]
