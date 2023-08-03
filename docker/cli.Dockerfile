# syntax=docker/dockerfile:experimental
FROM debian:bullseye

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
apt update && apt install -qy libnl-3-200 libnl-genl-3-200 libnl-route-3-200 libnl-nf-3-200 libhiredis0.14 python3 libpython3-dev python3-setuptools python3-pip openssl libssl-dev swig build-essential

RUN --mount=type=bind,source=sm/sonic-py-swsssdk,target=/root,rw cd /root && python3 setup.py install
RUN python3 -m pip install jinja2==2.11.2 zipp==1.2.0 importlib-resources==3.3.1 markupsafe==2.0.1 PyYAML==5.4.1
RUN --mount=type=bind,source=sm/sonic-buildimage/src/sonic-yang-models,target=/root,rw cd /root && python3 setup.py install
RUN --mount=type=bind,source=sm/sonic-buildimage/src/sonic-yang-mgmt,target=/root,rw cd /root && python3 setup.py install
RUN --mount=type=bind,source=sm/sonic-buildimage/src/sonic-py-common,target=/root,rw cd /root && python3 setup.py install
RUN --mount=type=bind,source=sm/sonic-buildimage/src/sonic-config-engine,target=/root,rw cd /root && python3 setup.py install
RUN python3 -m pip install netifaces tabulate netaddr natsort==6.2.1 click fastentrypoints
RUN --mount=type=bind,source=sm/sonic-platform-common,target=/root,rw cd /root && python3 setup.py install
RUN --mount=type=bind,source=sm/sonic-utilities,target=/root,rw cd /root && python3 setup.py install
