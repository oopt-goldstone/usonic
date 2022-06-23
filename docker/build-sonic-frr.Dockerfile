# syntax=docker/dockerfile:experimental
FROM debian:buster

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
apt update && apt install -qy make g++ graphviz autotools-dev autoconf doxygen stgit libnl-genl-3-dev libnl-nf-3-dev libhiredis-dev perl libxml-simple-perl aspell swig libgtest-dev dh-exec debhelper libtool python3-all python-all libpython3-dev libpython-dev quilt patchelf libboost-dev libc-ares-dev libsnmp-dev libjson-c3 libjson-c-dev libsystemd-dev python-ipaddr libcmocka-dev python3-all-dev python3-all-dbg install-info logrotate bison chrpath flex gawk libcap-dev libpam0g-dev libpam-dev libpcre3-dev libreadline-dev pkg-config python3-sphinx python3-pytest texinfo libelf-dev libpcre2-dev wget lsof

RUN wget https://ci1.netdef.org/artifact/LIBYANG-LIBYANGV2/shared/build-10/Debian-10-x86_64-Packages/libyang2_2.0.7-1~deb10u1_amd64.deb && dpkg -i *deb && cp *deb /tmp/
RUN wget https://ci1.netdef.org/artifact/LIBYANG-LIBYANGV2/shared/build-10/Debian-10-x86_64-Packages/libyang2-dev_2.0.7-1~deb10u1_amd64.deb && dpkg -i *deb && cp *deb /tmp/

RUN --mount=type=bind,target=/root,rw cd /root && make -C /root/make/sonic-frr


