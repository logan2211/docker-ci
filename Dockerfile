FROM ubuntu:16.04

# Use local apt mirrors
RUN sed -ri 's%(archive|security).ubuntu.com%mirror.lstn.net%' \
    /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y \
      sudo curl build-essential python2.7 python-dev git-core libffi-dev \
      libssl-dev nano && rm -rf /var/lib/apt/lists/*

# Install pip
RUN curl --silent --show-error --retry 5 \
    https://bootstrap.pypa.io/get-pip.py | sudo python2.7

# Install python packages
RUN pip install ansible ansible-lint tox


RUN useradd -m -G users,sudo ubuntu && \
    echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-ubuntu
USER ubuntu
