# syntax=docker/dockerfile:experimental
FROM debian:buster

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
apt update && apt install -qy --no-install-recommends make g++ graphviz autotools-dev autoconf doxygen libnl-3-dev libnl-genl-3-dev libnl-route-3-dev libnl-nf-3-dev libhiredis-dev perl libxml-simple-perl aspell swig libgtest-dev dh-exec debhelper libtool pkg-config python3-all python-all libpython3-dev libpython-dev quilt patchelf

RUN --mount=type=bind,target=/root,rw cd /root && quilt push -a && make -C /root/make/swss-common
RUN --mount=type=bind,target=/root,rw cd /root && quilt push -a && make -C /root/make/sairedis
RUN --mount=type=bind,target=/root,rw cd /root && quilt push -a && make -C /root/make/swss
