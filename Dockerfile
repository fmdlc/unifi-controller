# hadolint ignore=DL3008
FROM ubuntu:focal

ARG VERSION=6.0.28
ARG MONGO_PACKAGE=mongodb-org
ARG MONGO_REPO=repo.mongodb.org

LABEL \
    org.opencontainers.image.vendor="Facu de la Cruz (tty0) <fmdlc.unix@gmail.com>" \
    org.opencontainers.image.url="https://github.com/fmdlc/unifi-controller" \
    org.opencontainers.image.title="UniFi Controller" \
    org.opencontainers.image.arch="ARM64" \
    org.opencontainers.image.version=$VERSION \
    org.opencontainers.image.source="https://github.com/goofball222/unifi.git" \
    org.opencontainers.image.licenses="Apache-2.0"

WORKDIR /usr/lib/unifi

ENV BOUND_PRIV=false
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBUG=false
ENV JVM_EXTRA_OPTS=""
ENV JVM_INIT_HEAP_SIZE=""
ENV JVM_MAX_HEAP_SIZE=1024
ENV PGID=10999
ENV PUID=10999
ENV RUN_CHOWN=true
ENV RUNAS_UID0=false
ENV MONGO_PACKAGE=${MONGO_PACKAGE}
ENV MONGO_REPO=${MONGO_REPO}
ENV MONGO_MAJOR 4.4
ENV MONGO_VERSION 4.4.0

COPY src /

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Initial setup
RUN groupadd -r unifi -g $PGID ; \
      useradd --no-log-init -r -u $PUID -g $PGID unifi ; \
      apt-get -y update ; \
      apt-get -y install --no-install-recommends \
        binutils \
        gosu \
        libcap2 \
        libcap2-bin \
        procps \
        mongodb-server \
        ca-certificates-java \
        openjdk-8-jre-headless \
        gnupg2 && \
      rm -rf /var/lib/apt/lists/*

# Finally we need tailo install Unifi Controller
RUN curl -sSL https://dl.ui.com/unifi/${VERSION}/unifi_sysvinit_all.deb -o /tmp/unifi-${VERSION}.deb  && \
      dpkg --force-all -i /tmp/unifi-${VERSION}.deb && \
      bash -c 'mkdir -p {data,logs,run,cert}' && \
      chown -R unifi:unifi /usr/lib/unifi && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*

EXPOSE 3478/udp 6789/tcp 8080/tcp 8443/tcp 8843/tcp 8880/tcp 10001/udp

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["unifi"]
