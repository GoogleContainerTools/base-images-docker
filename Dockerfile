FROM scratch
ENV DEBIAN_FRONTEND noninteractive
ADD google-debian-wheezy.tar.xz /
CMD ["/bin/bash"]
