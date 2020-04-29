FROM quay.io/loganv/docker-ci:ubuntu-focal

USER root

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y s3cmd && rm -rf /var/lib/apt/lists/*

USER ubuntu

RUN virtualenv ~/.openstack && \
    echo 'source ~/.local_profile' >> ~/.profile && \
    ~/.openstack/bin/pip install python-openstackclient
ENV PATH="/home/ubuntu/.openstack/bin:${PATH}"


COPY limestone-openrc /home/ubuntu
COPY buildvm /home/ubuntu/.buildvm
COPY profile /home/ubuntu/.local_profile
COPY s3cmd.cfg /home/ubuntu/.s3cfg
CMD bash -l
