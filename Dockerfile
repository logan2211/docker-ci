FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

COPY etc /etc

RUN apt-get update && \
    apt-get install -y \
      systemd sudo curl iproute2 wget python3 python3-distutils \
      git-core nano iputils-ping && rm -rf /var/lib/apt/lists/*

# See tozd/ubuntu-systemd
# tweaks for systemd
RUN systemctl mask -- \
    -.mount \
    dev-ttyS0.device \
    dev-mqueue.mount \
    dev-hugepages.mount \
    proc-bus.mount \
    proc-irq.mount \
    proc-kcore.mount \
    proc-sys-fs-binfmt_misc.mount \
    proc-sysrq\\\\x2dtrigger.mount \
    sys-fs-fuse-connections.mount \
    sys-kernel-config.mount \
    sys-kernel-debug.mount \
    tmp.mount \
 \
 && systemctl mask -- \
    console-getty.service \
    display-manager.service \
    getty-static.service \
    getty\@tty1.service \
    hwclock-save.service \
    ondemand.service \
    systemd-logind.service \
    systemd-remount-fs.service \
 \
 && ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target \
 \
 && ln -sf /lib/systemd/system/halt.target /etc/systemd/system/sigpwr.target

# Set stop signal for systemd containers
STOPSIGNAL SIGRTMIN+3

# Install pip
RUN curl --silent --show-error --retry 5 \
    https://bootstrap.pypa.io/get-pip.py | sudo python3

# Install python packages
RUN pip install ansible ansible-lint tox netaddr

RUN useradd -m -G users,sudo ubuntu && \
    echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-ubuntu && \
    echo "Set disable_coredump false" >> /etc/sudo.conf

# Use local apt mirrors
RUN sed -ri 's%(archive|security).ubuntu.com%cache.mirror.lstn.net%' \
    /etc/apt/sources.list

# Add Limestone CA certificate
RUN curl https://mirror.lstn.net/limestone-ca.crt > \
      /usr/local/share/ca-certificates/limestone-ca.crt && \
    update-ca-certificates

USER ubuntu
