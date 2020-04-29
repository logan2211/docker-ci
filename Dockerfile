ARG DEBIAN_FRONTEND=noninteractive
FROM quay.io/loganv/docker-ci:ubuntu-focal as build

USER root

RUN apt-get update && \
    apt-get install -y gcc python3-dev && \
    rm -rf /var/lib/apt/lists/*

USER ubuntu

RUN virtualenv ~/.openstack && \
    ~/.openstack/bin/pip install python-openstackclient

FROM quay.io/loganv/docker-ci:ubuntu-focal as final

USER root

RUN apt-get update && \
    apt-get install -y s3cmd && \
    rm -rf /var/lib/apt/lists/*

USER ubuntu

COPY --from=build /home/ubuntu/.openstack /home/ubuntu/.openstack
RUN echo 'source ~/.local_profile' >> ~/.profile
ENV PATH="/home/ubuntu/.openstack/bin:${PATH}"

COPY limestone-openrc /home/ubuntu
COPY buildvm /home/ubuntu/.buildvm
COPY profile /home/ubuntu/.local_profile
COPY s3cmd.cfg /home/ubuntu/.s3cfg
CMD ["bash", "-l"]
