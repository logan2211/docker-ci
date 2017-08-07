FROM quay.io/loganv/docker-ci:ubuntu-xenial

RUN virtualenv ~/.openstack && \
    echo 'source ~/.local_profile' >> ~/.profile && \
    ~/.openstack/bin/pip install python-openstackclient

COPY limestone-openrc /home/ubuntu
COPY buildvm /home/ubuntu/.buildvm
COPY profile /home/ubuntu/.local_profile
CMD bash -l
