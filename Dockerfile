FROM debian:latest

ENV IPTABLES_SYNC_INTERVAL=60
ENV IPTABLES_CONFIGMAP_NAME=iptables-rules

ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

RUN apt-get update && \
    apt-get install -y curl jq iptables && \
    rm -rf /var/lib/apt/lists/*

RUN update-alternatives --set iptables /usr/sbin/iptables-legacy && \
    update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

COPY iptables-sync.sh /

CMD ["/iptables-sync.sh"]
