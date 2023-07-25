# syntax=docker/dockerfile:experimental
FROM debian:buster

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
apt update && apt install -qy --no-install-recommends make g++ graphviz autotools-dev autoconf doxygen libnl-3-dev libnl-genl-3-dev libnl-route-3-dev libnl-nf-3-dev libhiredis-dev perl libxml-simple-perl aspell swig libgtest-dev dh-exec debhelper libtool pkg-config python3-all python-all libpython3-dev libpython-dev quilt patchelf libboost-dev libgmock-dev build-essential

RUN --mount=type=bind,source=sm/sonic-swss-common,target=/root/sm/sonic-swss-common,rw \
    --mount=type=tmpfs,target=/root/.pc,rw \
    --mount=type=bind,source=make/swss-common,target=/root/make/swss-common \
    make -C /root/make/swss-common
