SONIC_FRR_DIR := ../../sm/sonic-frr

all:
#	cd $(SONIC_FRR_DIR) && tools/tarsource.sh -V -e '-sonic'
	cd $(SONIC_FRR_DIR) && dpkg-buildpackage -us -uc -b -Ppkg.frr.nortrlib && cd ../ && dpkg -i *.deb && cp *.deb /tmp/
        

