FROM opensuse:42.3

RUN zypper -q --gpg-auto-import-keys -n ref -f && \
    zypper -q -n in -l \
      sudo gcc curl python python-xml python-devel git-core libffi-devel \
      libopenssl-devel nano iproute2

# Install pip
RUN curl --silent --show-error --retry 5 \
    https://bootstrap.pypa.io/get-pip.py | sudo python2.7

# Install python packages
RUN pip install ansible ansible-lint tox

RUN useradd -m opensuse && \
    echo 'opensuse ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-opensuse

USER opensuse
