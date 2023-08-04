# syntax=docker/dockerfile:1.2
FROM debian:buster AS swss-common

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt,sharing=locked  \
apt update && apt install -qy make g++ graphviz autotools-dev autoconf doxygen libnl-3-dev libnl-genl-3-dev libnl-route-3-dev libnl-nf-3-dev libhiredis-dev perl libxml-simple-perl aspell swig libgtest-dev dh-exec debhelper libtool pkg-config python3-all python-all libpython3-dev libpython-dev quilt patchelf libboost-dev

RUN --mount=type=bind,source=sm/sonic-swss-common,target=/root/sm/sonic-swss-common,rw \
    --mount=type=bind,source=patches/sonic-swss-common,target=/root/patches \
    --mount=type=tmpfs,target=/root/.pc,rw \
    --mount=type=bind,source=make/swss-common,target=/root/make/swss-common \
    cd /root && quilt upgrade && quilt push -a && \
    make -C /root/make/swss-common

FROM debian:buster AS sairedis

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt,sharing=locked  \
apt update && apt install -qy make g++ graphviz autotools-dev autoconf doxygen libnl-3-dev libnl-genl-3-dev libnl-route-3-dev libnl-nf-3-dev libhiredis-dev perl libxml-simple-perl aspell swig libgtest-dev dh-exec debhelper libtool pkg-config python3-all python-all libpython3-dev libpython-dev quilt patchelf libboost-dev

RUN --mount=type=bind,source=/tmp,target=/tmp,from=swss-common dpkg -i /tmp/*.deb

RUN --mount=type=bind,source=sm/sonic-sairedis,target=/root/sm/sonic-sairedis,rw \
    --mount=type=bind,source=patches/sonic-sairedis,target=/root/patches \
    --mount=type=tmpfs,target=/root/.pc,rw \
    --mount=type=bind,source=make/sairedis,target=/root/make/sairedis \
    cd /root && quilt upgrade && quilt push -a && \
    make -C /root/make/sairedis

FROM debian:buster AS libteam

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt,sharing=locked  \
apt update && apt install -qy make g++ graphviz autotools-dev autoconf doxygen stgit libnl-genl-3-dev libnl-nf-3-dev libhiredis-dev perl libxml-simple-perl aspell swig libgtest-dev dh-exec debhelper libtool python3-all python-all libpython3-dev libpython-dev quilt patchelf libboost-dev libdaemon-dev libdbus-1-dev libjansson-dev libnl-3-dev libnl-cli-3-dev libnl-genl-3-dev libnl-route-3-dev pkg-config

RUN --mount=type=bind,source=/tmp,target=/tmp,from=swss-common dpkg -i /tmp/*.deb
RUN --mount=type=bind,source=./sm/libteam,target=/root/sm/libteam,rw \
    --mount=type=bind,source=./make/libteam,target=/root/make/libteam,rw \
    cd /root && make -C /root/sm/libteam && make -C /root/make/libteam

FROM debian:buster AS swss

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt,sharing=locked  \
apt update && apt install -qy --no-install-recommends make g++ graphviz autotools-dev autoconf doxygen libnl-3-dev libnl-genl-3-dev libnl-route-3-dev libnl-nf-3-dev libhiredis-dev perl libxml-simple-perl aspell swig libgtest-dev dh-exec debhelper libtool pkg-config python3-all python-all libpython3-dev libpython-dev quilt patchelf libboost-dev libteam-dev build-essential libdaemon-dev libdbus-1-dev libjansson-dev libnl-3-dev libnl-cli-3-dev libnl-genl-3-dev libnl-route-3-dev pkg-config libbsd-dev check libsnmp-dev libpci-dev libxml2-dev libevent-dev libreadline-dev libcap-dev

RUN --mount=type=bind,source=/tmp,target=/tmp,from=swss-common dpkg -i /tmp/*.deb
RUN --mount=type=bind,source=/tmp,target=/tmp,from=sairedis dpkg -i /tmp/*.deb
RUN --mount=type=bind,source=/tmp,target=/tmp,from=libteam dpkg -i /tmp/*.deb

RUN --mount=type=bind,source=sm/sonic-swss,target=/root/sm/sonic-swss,rw \
    --mount=type=bind,source=patches/sonic-swss,target=/root/patches \
    --mount=type=tmpfs,target=/root/.pc,rw \
    --mount=type=bind,source=make/swss,target=/root/make/swss \
    cd /root && quilt upgrade && quilt push -a && \
    make -C /root/make/swss

FROM debian:buster AS lldpd

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt,sharing=locked  \
apt update && apt install -qy make g++ graphviz autotools-dev autoconf doxygen stgit libnl-genl-3-dev libnl-nf-3-dev libhiredis-dev perl libxml-simple-perl aspell swig libgtest-dev dh-exec debhelper libtool python3-all python-all libpython3-dev libpython-dev quilt patchelf libboost-dev libbsd-dev pkg-config check libsnmp-dev libpci-dev libxml2-dev libevent-dev libreadline-dev libcap-dev libjansson-dev dh-systemd python3 python python-pip wget

RUN --mount=type=bind,source=sm/sonic-py-swsssdk,target=/root/sm/sonic-py-swsssdk,rw \
    --mount=type=bind,source=patches/sonic-py-swsssdk,target=/root/patches \
    --mount=type=tmpfs,target=/root/.pc,rw \
    cd /root && quilt upgrade && quilt push -a && \
    pip install /root/sm/sonic-py-swsssdk

# TODO refactoring
RUN --mount=type=bind,target=/root,rw \
    cd /root/sm/sonic-dbsyncd && \
    git config --global user.email goldstone-nos@googlegroups.com && \
    git config --global user.name "Goldstone" && \
    git am ../../patches/lldpd/patch/0001-lldp-syncd-fix.patch && pip install .

RUN --mount=type=bind,source=/tmp,target=/tmp,from=swss-common dpkg -i /tmp/*.deb
RUN --mount=type=bind,target=/root,rw cd /root && make -C /root/src/lldpd && quilt push -a && make -C /root/make/lldpd

FROM debian:buster AS sonic-frr

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt,sharing=locked  \
apt update && apt install -qy make g++ graphviz autotools-dev autoconf doxygen stgit libnl-genl-3-dev libnl-nf-3-dev libhiredis-dev perl libxml-simple-perl aspell swig libgtest-dev dh-exec debhelper libtool python3-all python-all libpython3-dev libpython-dev quilt patchelf libboost-dev libc-ares-dev libsnmp-dev libjson-c3 libjson-c-dev libsystemd-dev python-ipaddr libcmocka-dev python3-all-dev python3-all-dbg install-info logrotate bison chrpath flex gawk libcap-dev libpam0g-dev libpam-dev libpcre3-dev libreadline-dev libyang-dev pkg-config python3-sphinx python3-pytest texinfo

RUN --mount=type=bind,source=make/sonic-frr,target=/root/make/sonic-frr,rw \
    --mount=type=bind,source=sm/sonic-frr,target=/root/sm/sonic-frr,rw \
    --mount=type=bind,source=.git,target=/root/.git,rw \
    make -C /root/make/sonic-frr

FROM debian:buster AS run

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt,sharing=locked  \
apt update && apt install -qy --no-install-recommends libnl-3-200 libnl-genl-3-200 libnl-route-3-200 libnl-nf-3-200 libhiredis0.14 socat iproute2 libteam5 libdaemon-dev libdbus-1-dev libjansson-dev libnl-3-dev libnl-cli-3-dev libnl-genl-3-dev libnl-route-3-dev pkg-config debhelper libdbus-1-3 libdaemon0 libjansson4 libc-ares2 iproute2 libpython2.7 libjson-c3 logrotate libunwind8 libjs-jquery libjs-underscore libsnmp30 libyang0.16 libbsd-dev check libsnmp-dev libpci-dev libxml2-dev libevent-dev libreadline-dev libcap-dev

RUN --mount=type=bind,from=swss-common,source=/tmp,target=/tmp ls /tmp/*.deb | awk '$0 !~ /python/ && $0 !~ /-dbg_/ && $0 !~ /-dev_/ { print $0 }' | xargs dpkg -i

RUN --mount=type=bind,from=sairedis,source=/tmp,target=/tmp ls /tmp/*.deb | awk '$0 !~ /python/ && $0 !~ /-dbg_/ && $0 !~ /-dev_/ { print $0 }' | xargs dpkg -i
RUN --mount=type=bind,from=sairedis,target=/tmp cp /tmp/usr/lib/x86_64-linux-gnu/libsaivs.so.0.0.0 /usr/lib/x86_64-linux-gnu/libsaivs.so.0.0.0
RUN cd /usr/lib/x86_64-linux-gnu/ && ln -s libsaivs.so libsai.so

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

FROM run AS debug

RUN rm -f /var/run/teamd/* && \
    mkdir -p /var/warmboot/teamd

RUN rm -f /var/run/lldpd.socket 

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt,sharing=locked  \
apt update && apt-get install -qy -y --no-install-recommends apt-utils libpython-dev strace vim gdb procps redis-server syslog-ng tcpdump libdaemon-dev libdbus-1-dev libjansson-dev libnl-3-dev libnl-cli-3-dev libnl-genl-3-dev libnl-route-3-dev pkg-config debhelper libdbus-1-3 libdaemon0 libjansson4 libc-ares2 iproute2 libpython2.7 libjson-c3 logrotate libunwind8 python3 python python-pip libbsd-dev check libsnmp-dev libpci-dev libxml2-dev libevent-dev libreadline-dev libcap-dev build-essential git quilt

ADD src/lldpd/lldpmgrd /usr/bin/
RUN pip install setuptools
RUN --mount=type=bind,source=sm/sonic-py-swsssdk,target=/root/sm/sonic-py-swsssdk,rw \
    --mount=type=bind,source=patches/sonic-py-swsssdk,target=/root/patches \
    --mount=type=tmpfs,target=/root/.pc,rw \
    cd /root && quilt upgrade && quilt push -a && \
    pip install /root/sm/sonic-py-swsssdk

# TODO refactoring
RUN --mount=type=bind,target=/root,rw \
    cd /root/sm/sonic-dbsyncd && \
    git config --global user.email goldstone-nos@googlegroups.com && \
    git config --global user.name "Goldstone" && \
    git am ../../patches/lldpd/patch/0001-lldp-syncd-fix.patch && pip install .

RUN --mount=type=bind,from=swss-common,source=/tmp,target=/tmp dpkg -i /tmp/*.deb

RUN --mount=type=bind,from=sairedis,source=/tmp,target=/tmp dpkg -i /tmp/*.deb

RUN --mount=type=bind,from=swss,source=/tmp,target=/tmp dpkg -i /tmp/*.deb

RUN --mount=type=bind,from=libteam,source=/tmp,target=/tmp dpkg -i /tmp/*.deb

RUN --mount=type=bind,from=sonic-frr,source=/tmp,target=/tmp dpkg -i /tmp/*.deb

RUN --mount=type=bind,from=lldpd,source=/tmp,target=/tmp dpkg -i /tmp/*.deb
