# syntax=docker/dockerfile:experimental
ARG USONIC_SWSS_COMMON_IMAGE=usonic-swss-common:latest
ARG USONIC_SAIREDIS_IMAGE=usonic-sairedis:latest
ARG USONIC_SWSS_IMAGE=usonic-swss:latest
ARG USONIC_LIBTEAM_IMAGE=usonic-libteam:latest
ARG USONIC_SONIC_FRR_IMAGE=usonic-sonic-frr:latest
ARG USONIC_LLDPD_IMAGE=usonic-lldpd:latest

FROM ${USONIC_SWSS_COMMON_IMAGE} as swss_common
FROM ${USONIC_SAIREDIS_IMAGE} as sairedis
FROM ${USONIC_SWSS_IMAGE} as swss
FROM ${USONIC_LIBTEAM_IMAGE} as libteam
FROM ${USONIC_SONIC_FRR_IMAGE} as sonic-frr
FROM ${USONIC_LLDPD_IMAGE} as lldpd

FROM debian:bullseye

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
apt update && apt install -qy --no-install-recommends  libhiredis0.14 socat iproute2 libteam5 libdaemon-dev libdbus-1-dev libjansson-dev  pkg-config debhelper libdbus-1-3 libdaemon0 libjansson4 libc-ares2 iproute2 libpython2.7 libjson-c-dev logrotate libunwind8 libjs-jquery libjs-underscore libsnmp40 libbsd-dev check libsnmp-dev libpci-dev libxml2-dev libevent-dev libreadline-dev libcap-dev libyaml-0-2 libzmq5 libteamdctl0 lsof libelf-dev libpcre2-dev kmod

RUN --mount=type=bind,from=swss_common,source=/tmp,target=/tmp ls /tmp/*.deb | awk '$0 !~ /python/ && $0 !~ /-dbg_/ && $0 !~ /-dev_/ { print $0 }' | xargs dpkg -i

RUN --mount=type=bind,from=sairedis,source=/tmp,target=/tmp ls /tmp/*.deb | awk '$0 !~ /python/ && $0 !~ /-dbg_/ && $0 !~ /-dev_/ { print $0 }' | xargs dpkg -i
RUN --mount=type=bind,from=sairedis,target=/tmp cp /tmp/usr/lib/libsai.so /usr/lib/x86_64-linux-gnu/libsai.so

RUN --mount=type=bind,from=swss,source=/tmp,target=/tmp ls /tmp/*.deb | awk '$0 !~ /python/ && $0 !~ /-dbg_/ && $0 !~ /-dev_/ { print $0 }' | xargs dpkg -i

RUN --mount=type=bind,from=libteam,source=/tmp,target=/tmp ls /tmp/*.deb | awk '$0 !~ /python/ && $0 !~ /-dbg_/ && $0 !~ /-dev_/ { print $0 }' | xargs dpkg -i

RUN --mount=type=bind,from=sonic-frr,source=/tmp,target=/tmp ls /tmp/*.deb | awk '$0 !~ /python/ && $0 !~ /-dbg_/ && $0 !~ /-dev_/ { print $0 }' | xargs dpkg -i

RUN --mount=type=bind,from=lldpd,source=/tmp,target=/tmp ls /tmp/*.deb | awk '$0 !~ /python/ && $0 !~ /-dbg_/ && $0 !~ /-dev_/ { print $0 }' | xargs dpkg -i

ADD https://sonicstorage.blob.core.windows.net/packages/20190307/dsserve?sv=2015-04-05&sr=b&sig=lk7BH3DtW%2F5ehc0Rkqfga%2BUCABI0UzQmDamBsZH9K6w%3D&se=2038-05-06T22%3A34%3A45Z&sp=r /usr/bin/dsserve
RUN chmod +x /usr/bin/dsserve

ADD https://sonicstorage.blob.core.windows.net/packages/20190307/bcmcmd?sv=2015-04-05&sr=b&sig=sUdbU7oVbh5exbXXHVL5TDFBTWDDBASHeJ8Cp0B0TIc%3D&se=2038-05-06T22%3A34%3A19Z&sp=r /usr/bin/bcmcmd
RUN chmod +x /usr/bin/bcmcmd

RUN printf '#!/bin/sh\n\nsocat unix-connect:/run/sswsyncd/sswsyncd.socket -\n' >> /usr/bin/bcmsh
RUN chmod +x /usr/bin/bcmsh
