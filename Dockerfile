FROM ubuntu:18.04

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get update && \
    apt-get install -y \
      systemd sudo curl iproute2 wget build-essential python3 python3-dev \
      git-core libffi-dev libssl-dev nano iputils-ping && rm -rf /var/lib/apt/lists/*

# See tozd/ubuntu-systemd
# tweaks for systemd
RUN systemctl mask -- \
    -.mount \
    dev-mqueue.mount \
    dev-hugepages.mount \
    etc-hosts.mount \
    etc-hostname.mount \
    etc-resolv.conf.mount \
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
    https://bootstrap.pypa.io/pip/3.6/get-pip.py | sudo python3 - --no-cache-dir

# Install python packages
RUN pip install --no-cache-dir ansible ansible-lint tox netaddr

RUN useradd -m -G users,sudo ubuntu && \
    echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-ubuntu

# Use local apt mirrors
RUN sed -ri 's%(archive|ports|security).ubuntu.com%cache.mirror.lstn.net%' \
    /etc/apt/sources.list

# Add Limestone CA certificate
RUN curl https://mirror.lstn.net/limestone-ca.crt > \
      /usr/local/share/ca-certificates/limestone-ca.crt && \
    update-ca-certificates

USER ubuntu
