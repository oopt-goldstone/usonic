SAIREDIS_DIR := ../../sm/sonic-sairedis

all: 
	cd $(SAIREDIS_DIR) && DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -rfakeroot -b -us -uc -j4 && cd ../ && rm libsaivs-dbg_1.0.0_amd64.deb libsaivs-dev_1.0.0_amd64.deb libsaivs_1.0.0_amd64.deb && dpkg -i *.deb && cp *.deb /tmp/
