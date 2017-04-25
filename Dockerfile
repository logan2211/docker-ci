FROM centos:7

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN yum makecache fast; \
    yum -y install deltarpm epel-release initscripts; \
    yum -y update; \
    yum -y install sudo which nano git curl \
      python-devel redhat-lsb-core

# Install pip
RUN curl --show-error --retry 5 \
    https://bootstrap.pypa.io/get-pip.py | sudo python2.7

RUN yum -y install python2-pyasn1 python2-pyOpenSSL python-ndg_httpsclient \
      libselinux-python libsemanage-python gcc gcc-c++ libffi-devel \
      openssl-devel

# Install python packages
RUN pip install ansible ansible-lint tox

RUN useradd -m -G users,wheel centos && \
    echo 'centos ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-centos

USER centos
