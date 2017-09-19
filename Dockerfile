FROM debian:stretch

RUN apt-get update && \
    apt-get install -y \
      sudo systemd curl build-essential python2.7 python-dev git-core \
      libffi-dev libssl-dev nano iputils-ping && rm -rf /var/lib/apt/lists/* \
      && apt-get clean

RUN cd /lib/systemd/system/sysinit.target.wants/ && \
		ls | grep -v systemd-tmpfiles-setup.service | xargs rm -f && \
		rm -f /lib/systemd/system/sockets.target.wants/*udev* && \
		systemctl mask -- \
			tmp.mount \
			etc-hostname.mount \
			etc-hosts.mount \
			etc-resolv.conf.mount \
			-.mount \
			swap.target \
			getty.target \
			getty-static.service \
			dev-mqueue.mount \
			systemd-tmpfiles-setup-dev.service \
			systemd-remount-fs.service \
			systemd-ask-password-wall.path \
			systemd-logind.service && \
		systemctl set-default multi-user.target || true

RUN sed -ri /etc/systemd/journald.conf \
			-e 's!^#?Storage=.*!Storage=volatile!'

# Install pip
RUN curl --silent --show-error --retry 5 \
    https://bootstrap.pypa.io/get-pip.py | sudo python2.7

# Install python packages
RUN pip install ansible ansible-lint tox netaddr


RUN useradd -m -G users,sudo debian && \
    echo 'debian ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-debian

# Use local apt mirrors
RUN sed -ri 's%deb.debian.org%mirror.lstn.net%' \
    /etc/apt/sources.list

# Add Limestone CA certificate
RUN curl https://mirror.lstn.net/limestone-ca.crt > \
      /usr/local/share/ca-certificates/limestone-ca.crt && \
    update-ca-certificates

USER debian
