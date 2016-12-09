## makefile automates the build and deployment for lein projects

# edit these if you want
APP_NAME=		nlparse
APP_SCR_NAME=		$(APP_NAME)

# docker config
DOCKER_PREFIX=		target/docker-image
DOCKER_IMG_NAME=	nlpserv

# where the stanford model files are located
#ZMODEL=		$(HOME)/opt/nlp/model

# location of the http://github.com/plandes/clj-zenbuild cloned directory
ZBHOME=			../clj-zenbuild

# clean the generated app assembly file
MLINK=			$(ZMODEL)
ADD_CLEAN+=		$(ASBIN_DIR) model

all:	docker

include $(ZBHOME)/src/mk/compile.mk
include $(ZBHOME)/src/mk/dist.mk

.PHONY: test
test:
	ln -s $(MLINK) || true
	lein test

.PHONY:	testserv
testserv:
	wget -q -O - 'http://localhost:8080/parse?utterance=My+name+is+Paul+Landes&pretty=true'

.PHONY: docker
docker:		$(DOCKER_PREFIX)

$(DOCKER_PREFIX):
#$(DOCKER_PREFIX):	$(DIST_BIN_DIR)
	@if [ -z "$(ZMODEL)" ] ; then \
		echo "missing zensol model dependency" ; \
		false ; \
	fi
	mkdir -p $(DOCKER_PREFIX)
	cp -r $(DIST_PREFIX)/$(APP_NAME_REF) $(DOCKER_PREFIX)
	cp src/docker/Dockerfile $(DOCKER_PREFIX)
	cp src/docker/$(ASBIN_NAME) $(DOCKER_PREFIX)/$(APP_SNAME_REF)/$(DIST_BIN_DNAME)
	cp -r $(ZMODEL) $(DOCKER_PREFIX)
	docker rmi $(DOCKER_IMG_NAME) || true
	docker build -t $(DOCKER_IMG_NAME) $(DOCKER_PREFIX)

.PHONY: login
login:
	docker exec -it $(DOCKER_IMG_NAME) bash

.PHONY: logs
logs:
	docker logs nlps -f
