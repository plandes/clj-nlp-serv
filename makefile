## makefile automates the build and deployment for lein projects

# edit these if you want
APP_NAME=		nlparse
APP_SCR_NAME=		$(APP_NAME)
APP_START_SCR=		src/sh/nlparsectrl
ZMODEL ?=		$(HOME)/opt/nlp/model
DOCKER_IMG_NAME=	nlpservice

# docker config
DOCKER_CMD=		docker
DOCKER_USER=		$(GITUSER)
DOCKER_DIST_PREFIX=	target/docker-app-dist
DOCKER_PREFIX=		target/docker-image
DOCKER_IMG_PREFIX=	$(DOCKER_PREFIX)/img
DOCKER_IMG=		$(DOCKER_USER)/$(DOCKER_IMG_NAME)

# location of the http://github.com/plandes/clj-zenbuild cloned directory
ZBHOME=			../clj-zenbuild

all:		info
	@echo "model: $(ZMODEL)"

include $(ZBHOME)/src/mk/compile.mk
include $(ZBHOME)/src/mk/model.mk
include $(ZBHOME)/src/mk/dist.mk


.PHONY:	testserv
testserv:
	wget -q -O - 'http://localhost:9100/parse?utterance=My+name+is+Paul+Landes&pretty=true'

$(DOCKER_DIST_PREFIX):
	make DIST_PREFIX=$(DOCKER_DIST_PREFIX) dist

$(DOCKER_PREFIX):	$(DOCKER_DIST_PREFIX)
	@if [ -z "$(ZMODEL)" ] ; then \
		echo "missing zensol model dependency" ; \
		false ; \
	fi
	mkdir -p $(DOCKER_PREFIX)
	mkdir -p $(DOCKER_IMG_PREFIX)
	cp -r $(DOCKER_DIST_PREFIX)/$(APP_NAME_REF) $(DOCKER_IMG_PREFIX)
	cp $(APP_START_SCR) $(DOCKER_IMG_PREFIX)
	cp src/docker/Dockerfile $(DOCKER_PREFIX)
	cp src/docker/$(ASBIN_NAME) $(DOCKER_IMG_PREFIX)/$(APP_SNAME_REF)/$(DIST_BIN_DNAME)
	cp -r $(ZMODEL) $(DOCKER_IMG_PREFIX)

.PHONY: dockerdist
dockerdist:	$(DOCKER_PREFIX)
	$(DOCKER_CMD) rmi $(DOCKER_IMG) || true
	$(DOCKER_CMD) build -t $(DOCKER_IMG) $(DOCKER_PREFIX)
	$(DOCKER_CMD) tag $(DOCKER_IMG) $(DOCKER_IMG):$(VER)

.PHONY:	dockerpush
dockerpush:	dockerdist
	$(DOCKER_CMD) push $(DOCKER_IMG)

.PHONY: dockerrm
dockerrm:
	$(DOCKER_CMD) rmi $(DOCKER_IMG):$(VER) || true
	$(DOCKER_CMD) rmi $(DOCKER_IMG) || true

.PHONY: ec2dist
ec2dist:	prepare-docker
	rm $(DOCKER_PREFIX)/$(APP_SNAME_REF)/$(DIST_BIN_DNAME)/$(ASBIN_NAME)
	cp src/sh/* $(DOCKER_PREFIX)

# http://glynjackson.org/weblog/tutorial-deploying-django-app-aws-elastic-beanstalk-using-docker/
.PHONY:	elastic-bs-deploy
elastic-bs-deploy:	prepare-docker
	cp src/docker/Dockerrun.aws.json $(DOCKER_PREFIX)
	cp -r src/docker/dot-elasticbeanstalk $(DOCKER_PREFIX)/.elasticbeanstalk
#	( cd $(DOCKER_PREFIX) ; eb create )
#	ERROR: Application version cannot be any larger than 512MB

.PHONY: login
login:
	$(DOCKER_CMD) exec -it $(DOCKER_IMG_NAME) bash

.PHONY: logs
logs:
	$(DOCKER_CMD) logs nlps -f
