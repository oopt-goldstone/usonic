ifndef DOCKER_CMD
    DOCKER_CMD=bash
endif

ifndef USONIC_IMAGE_TAG
    USONIC_IMAGE_TAG=202205
endif

ifndef USONIC_RUN_IMAGE
    USONIC_RUN_IMAGE=usonic
endif

ifndef USONIC_DEBUG_IMAGE
    USONIC_DEBUG_IMAGE=usonic-debug
endif

ifndef USONIC_SWSS_COMMON_IMAGE
    USONIC_SWSS_COMMON_IMAGE=usonic-swss-common
endif

ifndef USONIC_SAIREDIS_IMAGE
    USONIC_SAIREDIS_IMAGE=usonic-sairedis
endif

ifndef USONIC_SWSS_IMAGE
    USONIC_SWSS_IMAGE=usonic-swss
endif

ifndef USONIC_LIBTEAM_IMAGE
    USONIC_LIBTEAM_IMAGE=usonic-libteam
endif

ifndef USONIC_SONIC_FRR_IMAGE
    USONIC_SONIC_FRR_IMAGE=usonic-sonic-frr
endif

ifndef USONIC_LLDPD_IMAGE
    USONIC_LLDPD_IMAGE=usonic-lldpd
endif

ifndef USONIC_CLI_IMAGE
    USONIC_CLI_IMAGE=usonic-cli
endif

ifndef DOCKER_REPO
    DOCKER_REPO := ghcr.io/microsonic
endif

ifndef DOCKER_IMAGE
    DOCKER_IMAGE := $(DOCKER_REPO)/$(USONIC_DEBUG_IMAGE):$(USONIC_IMAGE_TAG)
endif

LIBTEAM_DIR := sm/libteam/
LLDPD_DIR := src/lldpd/

LLDPD_SYNC_DIR := sm/sonic-dbsyncd/
LLDPD_PATCH := ../../patches/lldpd/patch/0001-lldp-syncd-fix.patch

all: swss-common sairedis libteam lldpd sonic-frr swss run-image debug-image

cli:
	DOCKER_BUILDKIT=1 docker build $(DOCKER_BUILD_OPTION) -f docker/cli.Dockerfile \
							      -t $(DOCKER_REPO)/$(USONIC_CLI_IMAGE):$(USONIC_IMAGE_TAG) .

swss-common:
	DOCKER_BUILDKIT=1 docker build $(DOCKER_BUILD_OPTION) -f docker/build-swss-common.Dockerfile \
							      -t $(DOCKER_REPO)/$(USONIC_SWSS_COMMON_IMAGE):$(USONIC_IMAGE_TAG) .

sonic-frr:
	DOCKER_BUILDKIT=1 docker build $(DOCKER_BUILD_OPTION) -f docker/build-sonic-frr.Dockerfile \
							      -t $(DOCKER_REPO)/$(USONIC_SONIC_FRR_IMAGE):$(USONIC_IMAGE_TAG) .

sairedis:
	DOCKER_BUILDKIT=1 docker build $(DOCKER_BUILD_OPTION) --build-arg USONIC_SWSS_COMMON_IMAGE=$(DOCKER_REPO)/$(USONIC_SWSS_COMMON_IMAGE):$(USONIC_IMAGE_TAG) \
							      -f docker/build-sairedis.Dockerfile \
							      -t $(DOCKER_REPO)/$(USONIC_SAIREDIS_IMAGE):$(USONIC_IMAGE_TAG) .

swss:
	DOCKER_BUILDKIT=1 docker build $(DOCKER_BUILD_OPTION) --build-arg USONIC_SWSS_COMMON_IMAGE=$(DOCKER_REPO)/$(USONIC_SWSS_COMMON_IMAGE):$(USONIC_IMAGE_TAG) \
							      --build-arg USONIC_SAIREDIS_IMAGE=$(DOCKER_REPO)/$(USONIC_SAIREDIS_IMAGE):$(USONIC_IMAGE_TAG) \
							      --build-arg USONIC_LIBTEAM_IMAGE=$(DOCKER_REPO)/$(USONIC_LIBTEAM_IMAGE):$(USONIC_IMAGE_TAG) \
							      --build-arg USONIC_LLDPD_IMAGE=$(DOCKER_REPO)/$(USONIC_LLDPD_IMAGE):$(USONIC_IMAGE_TAG) \
							      -f docker/build-swss.Dockerfile \
							      -t $(DOCKER_REPO)/$(USONIC_SWSS_IMAGE):$(USONIC_IMAGE_TAG) .

libteam:
	cd $(LIBTEAM_DIR) && make all

	DOCKER_BUILDKIT=1 docker build $(DOCKER_BUILD_OPTION) --build-arg USONIC_SWSS_COMMON_IMAGE=$(DOCKER_REPO)/$(USONIC_SWSS_COMMON_IMAGE):$(USONIC_IMAGE_TAG) \
							      -f docker/build-libteam.Dockerfile \
							      -t $(DOCKER_REPO)/$(USONIC_LIBTEAM_IMAGE):$(USONIC_IMAGE_TAG) .

lldpd:
	cd $(LLDPD_DIR) && make all

	DOCKER_BUILDKIT=1 docker build $(DOCKER_BUILD_OPTION) --build-arg USONIC_SWSS_COMMON_IMAGE=$(DOCKER_REPO)/$(USONIC_SWSS_COMMON_IMAGE):$(USONIC_IMAGE_TAG) \
							      -f docker/build-lldpd.Dockerfile \
							      -t $(DOCKER_REPO)/$(USONIC_LLDPD_IMAGE):$(USONIC_IMAGE_TAG) .

run-image:
	DOCKER_BUILDKIT=1 docker build $(DOCKER_BUILD_OPTION) --build-arg USONIC_SWSS_COMMON_IMAGE=$(DOCKER_REPO)/$(USONIC_SWSS_COMMON_IMAGE):$(USONIC_IMAGE_TAG) \
							      --build-arg USONIC_SAIREDIS_IMAGE=$(DOCKER_REPO)/$(USONIC_SAIREDIS_IMAGE):$(USONIC_IMAGE_TAG) \
							      --build-arg USONIC_SWSS_IMAGE=$(DOCKER_REPO)/$(USONIC_SWSS_IMAGE):$(USONIC_IMAGE_TAG) \
							      --build-arg USONIC_LIBTEAM_IMAGE=$(DOCKER_REPO)/$(USONIC_LIBTEAM_IMAGE):$(USONIC_IMAGE_TAG) \
							      --build-arg USONIC_SONIC_FRR_IMAGE=$(DOCKER_REPO)/$(USONIC_SONIC_FRR_IMAGE):$(USONIC_IMAGE_TAG) \
							      --build-arg USONIC_LLDPD_IMAGE=$(DOCKER_REPO)/$(USONIC_LLDPD_IMAGE):$(USONIC_IMAGE_TAG) \
							      -f docker/run.Dockerfile \
							      -t $(DOCKER_REPO)/$(USONIC_RUN_IMAGE):$(USONIC_IMAGE_TAG) .

debug-image:
	DOCKER_BUILDKIT=1 docker build $(DOCKER_BUILD_OPTION) --build-arg USONIC_SWSS_COMMON_IMAGE=$(DOCKER_REPO)/$(USONIC_SWSS_COMMON_IMAGE):$(USONIC_IMAGE_TAG) \
							      --build-arg USONIC_SAIREDIS_IMAGE=$(DOCKER_REPO)/$(USONIC_SAIREDIS_IMAGE):$(USONIC_IMAGE_TAG) \
							      --build-arg USONIC_SWSS_IMAGE=$(DOCKER_REPO)/$(USONIC_SWSS_IMAGE):$(USONIC_IMAGE_TAG) \
							      --build-arg USONIC_LIBTEAM_IMAGE=$(DOCKER_REPO)/$(USONIC_LIBTEAM_IMAGE):$(USONIC_IMAGE_TAG) \
							      --build-arg USONIC_SONIC_FRR_IMAGE=$(DOCKER_REPO)/$(USONIC_SONIC_FRR_IMAGE):$(USONIC_IMAGE_TAG) \
							      --build-arg USONIC_LLDPD_IMAGE=$(DOCKER_REPO)/$(USONIC_LLDPD_IMAGE):$(USONIC_IMAGE_TAG) \
							      --build-arg USONIC_RUN_IMAGE=$(DOCKER_REPO)/$(USONIC_RUN_IMAGE):$(USONIC_IMAGE_TAG) \
							      -f docker/debug.Dockerfile \
							      -t $(DOCKER_REPO)/$(USONIC_DEBUG_IMAGE):$(USONIC_IMAGE_TAG) .

run:
	-kubectl delete pods --force --grace-period=0 --timeout=0 usonic
	kubectl create -f ./files/usonic.yaml

bash:
	$(MAKE) cmd

cmd:
	docker run -it -v `pwd`:/data -w /data --privileged --rm $(DOCKER_IMAGE) $(DOCKER_CMD)
