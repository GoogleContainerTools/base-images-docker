FROM bazel/reproducible:ubuntu_vanilla
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y -q \
      curl \
      netbase \
      ca-certificates && \
    apt-get clean && \
    rm /var/lib/apt/lists/*_*
