.ONESHELL:
SHELL = /bin/bash
.SHELLFLAGS += -e
LLDPD_DIR := ../../src/lldpd

LLDPD_VERSION = 0.9.6
LLDPD_VERSION_SUFFIX = 1
LLDPD_VERSION_FULL = $(LLDPD_VERSION)-$(LLDPD_VERSION_SUFFIX)

LLDP_URL = http://ftp.debian.org/debian/pool/main/l/lldpd

DSC_FILE = lldpd_$(LLDPD_VERSION_FULL).dsc
ORIG_FILE = lldpd_$(LLDPD_VERSION).orig.tar.gz
DEBIAN_FILE = lldpd_$(LLDPD_VERSION_FULL).debian.tar.xz

DSC_FILE_URL = $(LLDP_URL)/$(DSC_FILE)
ORIG_FILE_URL = $(LLDP_URL)/$(ORIG_FILE)
DEBIAN_FILE_URL = $(LLDP_URL)/$(DEBIAN_FILE)

all:
	# Remove any stale files
	rm -rf lldpd-$(LLDPD_VERSION)

	# download debian LLDPDD
	wget -NO "$(DSC_FILE)" $(DSC_FILE_URL)
	wget -NO "$(ORIG_FILE)" $(ORIG_FILE_URL)
	wget -NO "$(DEBIAN_FILE)" $(DEBIAN_FILE_URL)
	dpkg-source -x lldpd_$(LLDPD_VERSION_FULL).dsc

	pushd lldpd-$(LLDPD_VERSION)
	git init
	git config user.name "PRAVEEN-BABY"
	git config user.email "BPraveen@palcnetworks.com"
	git add -f *
	git commit -m "unmodified lldp source"
	popd

