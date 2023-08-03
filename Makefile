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

ifndef USONIC_CLI_IMAGE
    USONIC_CLI_IMAGE=usonic-cli
endif

ifndef DOCKER_REPO
    DOCKER_REPO := ghcr.io/oopt-goldstone
endif

ifndef DOCKER_IMAGE
    DOCKER_IMAGE := $(DOCKER_REPO)/$(USONIC_DEBUG_IMAGE):$(USONIC_IMAGE_TAG)
endif

all: cli run-image debug-image

run-image:
	DOCKER_BUILDKIT=1 docker build $(DOCKER_BUILD_OPTION) \
									--target run \
									-f docker/build.Dockerfile \
									-t $(DOCKER_REPO)/$(USONIC_RUN_IMAGE):$(USONIC_IMAGE_TAG) .

debug-image:
	DOCKER_BUILDKIT=1 docker build $(DOCKER_BUILD_OPTION) \
									--target debug \
									-f docker/build.Dockerfile \
									-t $(DOCKER_REPO)/$(USONIC_DEBUG_IMAGE):$(USONIC_IMAGE_TAG) .

cli:
	DOCKER_BUILDKIT=1 docker build $(DOCKER_BUILD_OPTION) -f docker/cli.Dockerfile \
							      -t $(DOCKER_REPO)/$(USONIC_CLI_IMAGE):$(USONIC_IMAGE_TAG) .

run:
	-kubectl delete pods --force --grace-period=0 --timeout=0 usonic
	kubectl create -f ./files/usonic.yaml

bash:
	$(MAKE) cmd

cmd:
	docker run -it -v `pwd`:/data -w /data --privileged --rm $(DOCKER_IMAGE) $(DOCKER_CMD)
