# syntax=docker/dockerfile:experimental
FROM debian:buster

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
apt update && apt install -qy libnl-3-200 libnl-genl-3-200 libnl-route-3-200 libnl-nf-3-200 libhiredis0.14 python libpython-dev python-setuptools python-pip

RUN --mount=type=bind,source=sm/sonic-py-swsssdk,target=/root,rw cd /root && python setup.py install
RUN pip install jinja2==2.11.2 zipp==1.2.0 importlib-resources==3.3.1
RUN --mount=type=bind,source=sm/sonic-buildimage/src/sonic-config-engine,target=/root,rw cd /root && python setup.py install
RUN pip install netifaces tabulate netaddr natsort==6.2.1 click
RUN --mount=type=bind,source=sm/sonic-utilities,target=/root,rw cd /root && python setup.py install
