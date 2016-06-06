DEBIAN_SUITE=jessie
DEBIAN_MIRROR=http://gce_debian_mirror.storage.googleapis.com/
DOCKER_REPO=google/debian
ROOTFS_TAR=google-debian-${DEBIAN_SUITE}.tar.bz2
MKIMAGE=mkimage-debootstrap.sh
MKIMAGE_URL=https://raw.githubusercontent.com/dotcloud/docker/master/contrib/mkimage-debootstrap.sh

.PHONY: docker-image update-mkimage clean

all: docker-image

docker-image: ${ROOTFS_TAR}
	docker build -t ${DOCKER_REPO}:${DEBIAN_SUITE} .

${ROOTFS_TAR}: ${MKIMAGE}
	./${MKIMAGE} -t ${ROOTFS_TAR} ${DEBIAN_SUITE} ${DEBIAN_MIRROR}

update-mkimage: 
	wget -N ${MKIMAGE_URL}

clean:
	rm -f ${ROOTFS_TAR}

build:
	cd builder && docker build \
		-t gae-builder \
		--build-arg DOCKER_VERSION=1.11.2 \
		--file builder.Dockerfile .
	rm -rf $(DEBIAN_SUITE)
	docker rm builder || true
	@# We need to run this container in privileged mode so it can run
	@# chroot as part of debootstrap
	docker run \
		--name builder \
		-it \
		--privileged \
		--volume /var/$(DEBIAN_SUITE) \
		gae-builder \
			-d /var/$(DEBIAN_SUITE) \
			debootstrap \
			--variant=minbase \
			$(DEBIAN_SUITE)
	docker cp builder:/var/$(DEBIAN_SUITE) .
