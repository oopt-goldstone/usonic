# syntax=docker/dockerfile:experimental
ARG USONIC_SWSS_COMMON_IMAGE=usonic-swss-common:latest
ARG USONIC_SAIREDIS_IMAGE=usonic-sairedis:latest
ARG USONIC_LIBTEAM_IMAGE=usonic-libteam:latest

FROM ${USONIC_SWSS_COMMON_IMAGE} as swss_common
FROM ${USONIC_SAIREDIS_IMAGE} as sairedis
FROM ${USONIC_LIBTEAM_IMAGE} as libteam

FROM debian:buster

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
apt update && apt install -qy --no-install-recommends make g++ graphviz autotools-dev autoconf doxygen  libhiredis-dev perl libxml-simple-perl aspell swig libgtest-dev dh-exec debhelper libtool pkg-config python3-all python-all libpython3-dev libpython-dev quilt patchelf libboost-dev libteam-dev build-essential libdaemon-dev libdbus-1-dev libjansson-dev pkg-config libbsd-dev check libsnmp-dev libpci-dev libxml2-dev libevent-dev libreadline-dev libcap-dev libzmq5-dev cdbs fakeroot bison flex libyaml-0-2


RUN apt-get update && apt-get install -y wget git
RUN --mount=type=bind,source=sm/sonic-buildimage/src/libnl3,target=/root/libnl3,rw \
    cd /root/libnl3 && wget https://github.com/thom311/libnl/archive/refs/tags/libnl3_5_0.tar.gz && tar -xvf libnl3_5_0.tar.gz && ls -lrt && cd libnl-libnl3_5_0 && ls -lrt && git apply ../patch/0001-mpls-encap-accessors.patch && git apply ../patch/0002-mpls-remove-nl_addr_valid.patch && ln -s ../debian debian && fakeroot dpkg-buildpackage -us -uc -b && cd /root/libnl3/ && dpkg -i *.deb &&  cp *.deb /tmp/ 

RUN --mount=type=bind,source=/tmp,target=/tmp,from=swss_common dpkg -i /tmp/*.deb
RUN --mount=type=bind,source=/tmp,target=/tmp,from=sairedis dpkg -i /tmp/*.deb
RUN --mount=type=bind,source=/tmp,target=/tmp,from=libteam dpkg -i /tmp/*.deb

RUN --mount=type=bind,source=sm/sonic-swss,target=/root/sm/sonic-swss,rw \
    --mount=type=tmpfs,target=/root/.pc,rw \
    --mount=type=bind,source=make/swss,target=/root/make/swss\
    make -C /root/make/swss
