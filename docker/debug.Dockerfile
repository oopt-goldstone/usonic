# syntax=docker/dockerfile:experimental
ARG USONIC_SWSS_COMMON_IMAGE=usonic-swss-common:latest
ARG USONIC_SAIREDIS_IMAGE=usonic-sairedis:latest
ARG USONIC_SWSS_IMAGE=usonic-swss:latest
ARG USONIC_RUN_IMAGE=usonic:latest
ARG USONIC_LIBTEAM_IMAGE=usonic-libteam:latest
ARG USONIC_SONIC_FRR_IMAGE=usonic-sonic-frr:latest
ARG USONIC_LLDPD_IMAGE=usonic-lldpd:latest

FROM ${USONIC_SONIC_FRR_IMAGE} as sonic-frr
FROM ${USONIC_LIBTEAM_IMAGE} as libteam
FROM ${USONIC_LLDPD_IMAGE} as lldpd
FROM ${USONIC_SWSS_COMMON_IMAGE} as swss_common
FROM ${USONIC_SAIREDIS_IMAGE} as sairedis
FROM ${USONIC_SWSS_IMAGE} as swss

FROM ${USONIC_RUN_IMAGE}

RUN rm -f /var/run/teamd/* && \
    mkdir -p /var/warmboot/teamd

RUN rm -f /var/run/lldpd.socket 

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
apt update && apt-get install -qy -y --no-install-recommends apt-utils libpython-dev strace vim gdb procps redis-server syslog-ng tcpdump libdaemon-dev libdbus-1-dev libjansson-dev  pkg-config debhelper libdbus-1-3 libdaemon0 libjansson4 libc-ares2 iproute2 libpython2.7 libjson-c3 logrotate libunwind8 python3 python python-pip libbsd-dev check libsnmp-dev libpci-dev libxml2-dev libevent-dev libreadline-dev libcap-dev build-essential libboost-dev libzmq5-dev

ADD src/lldpd/lldpmgrd /usr/bin/
RUN pip install setuptools
RUN --mount=type=bind,source=sm/sonic-py-swsssdk,target=/src,rw pip install /src
RUN --mount=type=bind,source=sm/sonic-dbsyncd,target=/src,rw pip install /src

RUN --mount=type=bind,from=swss_common,source=/tmp,target=/tmp dpkg -i /tmp/*.deb

RUN --mount=type=bind,from=sairedis,source=/tmp,target=/tmp dpkg -i /tmp/*.deb

RUN --mount=type=bind,from=swss,source=/tmp,target=/tmp dpkg -i /tmp/*.deb

RUN --mount=type=bind,from=libteam,source=/tmp,target=/tmp dpkg -i /tmp/*.deb

RUN --mount=type=bind,from=sonic-frr,source=/tmp,target=/tmp dpkg -i /tmp/*.deb

RUN --mount=type=bind,from=lldpd,source=/tmp,target=/tmp dpkg -i /tmp/*.deb
