LLDPD_DIR := ../../src/lldpd/lldpd-0.9.6/
LLDPD_PATCH := ../../../patches/lldpd/patch/series

all:
	cd $(LLDPD_DIR) && stg init
	cd $(LLDPD_DIR) && stg import -s $(LLDPD_PATCH)
	
	cd $(LLDPD_DIR) && dpkg-buildpackage -us -uc -b -d && cd ../ && dpkg -i *.deb && cp *.deb /tmp/
