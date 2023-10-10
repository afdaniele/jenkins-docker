ARG JENKINS_VERSION

FROM jenkins/jenkins:${JENKINS_VERSION}

# define arguments
ARG DOCKER_DOWNLOAD_URL="https://download.docker.com/linux/static/stable"
ARG DOCKER_ARCH="x86_64"
ARG DOCKER_VERSION="20.10.21"

ARG DOCKER_BUILDKIT_DOWNLOAD_URL="https://github.com/docker/buildx/releases/download"
ARG DOCKER_BUILDKIT_ARCH="amd64"
ARG DOCKER_BUILDKIT_VERSION="v0.10.5"

USER root

# install dependencies
RUN apt update \
  && apt install -y \
    sudo \
    make \
    wget \
  && rm -rf /var/lib/apt/lists/*

# install docker binaries
RUN cd /tmp \
  # download binaries
  && wget \
    "${DOCKER_DOWNLOAD_URL}/${DOCKER_ARCH}/docker-${DOCKER_VERSION}.tgz" \
    -O ./docker-bin.tgz \
  # extract binaries
  && tar -zxvf ./docker-bin.tgz \
  # copy binaries to system dir
  && cp ./docker/* /usr/local/bin \
  # clean up temp files
  && rm -rf \
    docker \
    docker-bin.tgz

# install docker buildkit
RUN cd /tmp \
  # make directories
  && mkdir -p /usr/lib/docker/cli-plugins \
  # download binaries
  && wget \
    "${DOCKER_BUILDKIT_DOWNLOAD_URL}/${DOCKER_BUILDKIT_VERSION}/buildx-${DOCKER_BUILDKIT_VERSION}.linux-${DOCKER_BUILDKIT_ARCH}" \
    -O /usr/lib/docker/cli-plugins/docker-buildx \
    # make it executable
    && chmod +x /usr/lib/docker/cli-plugins/docker-buildx

# install libraries
RUN apt update \
  && apt install -y \
    python3 \
    python3-pip \
  && rm -rf /var/lib/apt/lists/*

# install cpk and rretry
RUN pip3 install --break-system-packages -U "cpk>=0.4.3" "run-and-retry"

# give the jenkins user the power to create groups
RUN echo 'jenkins ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/jenkins_no_password

USER jenkins

# copy entrypoint
COPY assets/entrypoint /entrypoint

ENTRYPOINT /entrypoint
