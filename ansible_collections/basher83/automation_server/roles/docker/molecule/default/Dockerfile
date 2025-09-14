FROM ubuntu:22.04

ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive

# Install systemd and other required packages
RUN apt-get update && \
    apt-get install -y \
        systemd \
        systemd-sysv \
        sudo \
        python3 \
        python3-pip \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        software-properties-common \
        apt-transport-https && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Remove unnecessary systemd services
RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*

VOLUME ["/sys/fs/cgroup"]

CMD ["/lib/systemd/systemd"]
