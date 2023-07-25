# syntax=docker/dockerfile:experimental
FROM debian:buster AS swss-common

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt,sharing=locked \
apt update && apt install -qy --no-install-recommends make g++ graphviz autotools-dev autoconf doxygen libnl-3-dev libnl-genl-3-dev libnl-route-3-dev libnl-nf-3-dev libhiredis-dev perl libxml-simple-perl aspell swig libgtest-dev dh-exec debhelper libtool pkg-config python3-all python-all libpython3-dev libpython-dev quilt patchelf libboost-dev libgmock-dev build-essential

RUN --mount=type=bind,source=sm/sonic-swss-common,target=/root/sm/sonic-swss-common,rw \
    --mount=type=tmpfs,target=/root/.pc,rw \
    --mount=type=bind,source=make/swss-common,target=/root/make/swss-common \
    make -C /root/make/swss-common

FROM debian:buster AS sairedis

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt,sharing=locked \
apt update && apt install -qy --no-install-recommends make g++ graphviz autotools-dev autoconf doxygen libnl-3-dev libnl-genl-3-dev libnl-route-3-dev libnl-nf-3-dev libhiredis-dev perl libxml-simple-perl aspell aspell-en swig3.0 libgtest-dev dh-exec debhelper libtool pkg-config libpython2.7-dev python3-all python-all libpython3-dev libpython-dev quilt patchelf libboost-dev libzmq3-dev libzmq5 autoconf-archive libyaml-0-2 wget build-essential

ADD https://sonicstorage.blob.core.windows.net/public/sai/bcmsai/REL_7.0/7.1.0.0-6/libsaibcm_7.1.0.0-6_amd64.deb /tmp/
ADD https://sonicstorage.blob.core.windows.net/public/sai/bcmsai/REL_7.0/7.1.0.0-6/libsaibcm-dev_7.1.0.0-6_amd64.deb /tmp/
RUN dpkg -i /tmp/*.deb

RUN --mount=type=bind,source=/tmp,target=/tmp,from=swss-common dpkg -i /tmp/*.deb

RUN --mount=type=bind,source=sm/sonic-sairedis,target=/root/sm/sonic-sairedis,rw \
    --mount=type=tmpfs,target=/root/.pc,rw \
    --mount=type=bind,source=make/sairedis,target=/root/make/sairedis \
    make -C /root/make/sairedis

FROM debian:buster AS libteam

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt,sharing=locked \
apt update && apt install -qy --no-install-recommends make g++ graphviz autotools-dev autoconf doxygen stgit libnl-genl-3-dev libnl-nf-3-dev libhiredis-dev perl libxml-simple-perl aspell swig libgtest-dev dh-exec debhelper libtool python3-all python-all libpython3-dev libpython-dev quilt patchelf libboost-dev libdaemon-dev libdbus-1-dev libjansson-dev libnl-3-dev libnl-cli-3-dev libnl-genl-3-dev libnl-route-3-dev pkg-config build-essential ca-certificates

RUN --mount=type=bind,source=/tmp,target=/tmp,from=swss-common dpkg -i /tmp/*.deb
RUN --mount=type=bind,source=./sm/libteam,target=/root/sm/libteam,rw \
    --mount=type=bind,source=./make/libteam,target=/root/make/libteam,rw \
    cd /root && make -C /root/sm/libteam && make -C /root/make/libteam

FROM debian:buster AS swss

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt,sharing=locked \
apt update && apt install -qy --no-install-recommends make g++ graphviz autotools-dev autoconf doxygen  libhiredis-dev perl libxml-simple-perl aspell swig libgtest-dev dh-exec debhelper libtool pkg-config python3-all python-all libpython3-dev libpython-dev quilt patchelf libboost-dev libteam-dev build-essential libdaemon-dev libdbus-1-dev libjansson-dev pkg-config libbsd-dev check libsnmp-dev libpci-dev libxml2-dev libevent-dev libreadline-dev libcap-dev libzmq5-dev cdbs fakeroot bison flex libyaml-0-2


RUN --mount=type=bind,source=sm/sonic-buildimage/src/libnl3,target=/root/libnl3,rw \
    apt-get update && apt-get install -y wget git && cd /root/libnl3 && wget https://github.com/thom311/libnl/archive/refs/tags/libnl3_5_0.tar.gz && tar -xvf libnl3_5_0.tar.gz && ls -lrt && cd libnl-libnl3_5_0 && ls -lrt && git apply ../patch/0001-mpls-encap-accessors.patch && git apply ../patch/0002-mpls-remove-nl_addr_valid.patch && ln -s ../debian debian && fakeroot dpkg-buildpackage -us -uc -b && cd /root/libnl3/ && dpkg -i *.deb &&  cp *.deb /tmp/ 

RUN --mount=type=bind,source=/tmp,target=/tmp,from=swss-common dpkg -i /tmp/*.deb
RUN --mount=type=bind,source=/tmp,target=/tmp,from=sairedis dpkg -i /tmp/*.deb
RUN --mount=type=bind,source=/tmp,target=/tmp,from=libteam dpkg -i /tmp/*.deb

RUN --mount=type=bind,source=sm/sonic-swss,target=/root/sm/sonic-swss,rw \
    --mount=type=bind,source=patches/sonic-swss,target=/root/patches \
    --mount=type=tmpfs,target=/root/.pc,rw \
    --mount=type=bind,source=make/swss,target=/root/make/swss \
    cd /root && quilt upgrade && quilt push -a && \
    make -C /root/make/swss

FROM debian:buster AS lldp

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt,sharing=locked \
apt update && apt install -qy --no-install-recommends make g++ graphviz autotools-dev autoconf doxygen stgit libnl-genl-3-dev libnl-nf-3-dev libhiredis-dev perl libxml-simple-perl aspell swig libgtest-dev dh-exec debhelper libtool python3-all python-all libpython3-dev libpython-dev quilt patchelf libboost-dev libbsd-dev pkg-config check libsnmp-dev libpci-dev libxml2-dev libevent-dev libreadline-dev libcap-dev libjansson-dev dh-systemd python3 python python3-pip build-essential python3-setuptools wget

RUN --mount=type=bind,source=sm/sonic-py-swsssdk,target=/src,rw pip3 install /src
RUN --mount=type=bind,source=sm/sonic-dbsyncd,target=/src,rw pip3 install /src
RUN --mount=type=bind,source=/tmp,target=/tmp,from=swss-common dpkg -i /tmp/*.deb
RUN --mount=type=bind,target=/root,rw cd /root && make -C /root/src/lldpd && make -C /root/make/lldpd

FROM debian:buster AS sonic-frr

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt,sharing=locked \
apt update && apt install -qy make g++ graphviz autotools-dev autoconf doxygen stgit libnl-genl-3-dev libnl-nf-3-dev libhiredis-dev perl libxml-simple-perl aspell swig libgtest-dev dh-exec debhelper libtool python3-all python-all libpython3-dev libpython-dev quilt patchelf libboost-dev libc-ares-dev libsnmp-dev libjson-c3 libjson-c-dev libsystemd-dev python-ipaddr libcmocka-dev python3-all-dev python3-all-dbg install-info logrotate bison chrpath flex gawk libcap-dev libpam0g-dev libpam-dev libpcre3-dev libreadline-dev pkg-config python3-sphinx python3-pytest texinfo libelf-dev libpcre2-dev wget lsof build-essential

RUN wget https://ci1.netdef.org/artifact/LIBYANG-LIBYANGV2/shared/build-10/Debian-10-x86_64-Packages/libyang2_2.0.7-1~deb10u1_amd64.deb && dpkg -i *deb && cp *deb /tmp/
RUN wget https://ci1.netdef.org/artifact/LIBYANG-LIBYANGV2/shared/build-10/Debian-10-x86_64-Packages/libyang2-dev_2.0.7-1~deb10u1_amd64.deb && dpkg -i *deb && cp *deb /tmp/

RUN --mount=type=bind,target=/root,rw cd /root && make -C /root/make/sonic-frr

FROM debian:buster AS run

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt,sharing=locked \
apt update && apt install -qy --no-install-recommends  libhiredis0.14 socat iproute2 libteam5 libdaemon-dev libdbus-1-dev libjansson-dev  pkg-config debhelper libdbus-1-3 libdaemon0 libjansson4 libc-ares2 iproute2 libpython2.7 libjson-c3 logrotate libunwind8 libjs-jquery libjs-underscore libsnmp30 libyang0.16 libbsd-dev check libsnmp-dev libpci-dev libxml2-dev libevent-dev libreadline-dev libcap-dev libyaml-0-2 libzmq5 libteamdctl0 lsof libelf-dev libpcre2-dev kmod

RUN --mount=type=bind,from=swss-common,source=/tmp,target=/tmp ls /tmp/*.deb | awk '$0 !~ /python/ && $0 !~ /-dbg_/ && $0 !~ /-dev_/ { print $0 }' | xargs dpkg -i

RUN --mount=type=bind,from=sairedis,source=/tmp,target=/tmp ls /tmp/*.deb | awk '$0 !~ /python/ && $0 !~ /-dbg_/ && $0 !~ /-dev_/ { print $0 }' | xargs dpkg -i
RUN --mount=type=bind,from=sairedis,target=/tmp cp /tmp/usr/lib/libsai.so /usr/lib/x86_64-linux-gnu/libsai.so

RUN --mount=type=bind,from=swss,source=/tmp,target=/tmp ls /tmp/*.deb | awk '$0 !~ /python/ && $0 !~ /-dbg_/ && $0 !~ /-dev_/ { print $0 }' | xargs dpkg -i

RUN --mount=type=bind,from=libteam,source=/tmp,target=/tmp ls /tmp/*.deb | awk '$0 !~ /python/ && $0 !~ /-dbg_/ && $0 !~ /-dev_/ { print $0 }' | xargs dpkg -i

RUN --mount=type=bind,from=sonic-frr,source=/tmp,target=/tmp ls /tmp/*.deb | awk '$0 !~ /python/ && $0 !~ /-dbg_/ && $0 !~ /-dev_/ { print $0 }' | xargs dpkg -i

RUN --mount=type=bind,from=lldp,source=/tmp,target=/tmp ls /tmp/*.deb | awk '$0 !~ /python/ && $0 !~ /-dbg_/ && $0 !~ /-dev_/ { print $0 }' | xargs dpkg -i

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

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt,sharing=locked \
apt update && apt-get install -qy -y --no-install-recommends apt-utils libpython-dev strace vim gdb procps redis-server syslog-ng tcpdump libdaemon-dev libdbus-1-dev libjansson-dev  pkg-config debhelper libdbus-1-3 libdaemon0 libjansson4 libc-ares2 iproute2 libpython2.7 libjson-c3 logrotate libunwind8 python3 python python-pip libbsd-dev check libsnmp-dev libpci-dev libxml2-dev libevent-dev libreadline-dev libcap-dev build-essential libboost-dev libzmq5-dev

ADD src/lldpd/lldpmgrd /usr/bin/
RUN pip install setuptools
RUN --mount=type=bind,source=sm/sonic-py-swsssdk,target=/src,rw pip install /src
RUN --mount=type=bind,source=sm/sonic-dbsyncd,target=/src,rw pip install /src

RUN --mount=type=bind,from=swss-common,source=/tmp,target=/tmp dpkg -i /tmp/*.deb

RUN --mount=type=bind,from=sairedis,source=/tmp,target=/tmp dpkg -i /tmp/*.deb

RUN --mount=type=bind,from=swss,source=/tmp,target=/tmp dpkg -i /tmp/*.deb

RUN --mount=type=bind,from=libteam,source=/tmp,target=/tmp dpkg -i /tmp/*.deb

RUN --mount=type=bind,from=sonic-frr,source=/tmp,target=/tmp dpkg -i /tmp/*.deb

RUN --mount=type=bind,from=lldp,source=/tmp,target=/tmp dpkg -i /tmp/*.deb
