## makefile automates the build and deployment for lein projects

# edit these if you want
APP_NAME=		nlparse
APP_SCR_NAME=		$(APP_NAME)
APP_START_SCR=		src/sh/nlparsectrl

# docker config
DOCKER_USER=		$(GITUSER)
DOCKER_DIST_PREFIX=	target/docker-app-dist
DOCKER_PREFIX=		target/docker-image
DOCKER_IMG_PREFIX=	$(DOCKER_PREFIX)/img
DOCKER_IMG_NAME=	nlpserv
DOCKER_IMG=		$(DOCKER_USER)/$(DOCKER_IMG_NAME):$(VER)

# where the stanford model files are located
#ZMODEL=		$(HOME)/opt/nlp/model

# location of the http://github.com/plandes/clj-zenbuild cloned directory
ZBHOME=			../clj-zenbuild

all:		dockerdist

include $(ZBHOME)/src/mk/compile.mk
include $(ZBHOME)/src/mk/model.mk
include $(ZBHOME)/src/mk/dist.mk

tmp:

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
	docker rmi $(DOCKER_IMG) || true
	docker build -t $(DOCKER_IMG) $(DOCKER_PREFIX)

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
	docker exec -it $(DOCKER_IMG_NAME) bash

.PHONY: logs
logs:
	docker logs nlps -f
