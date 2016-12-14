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

all:		info

include $(ZBHOME)/src/mk/compile.mk
include $(ZBHOME)/src/mk/dist.mk


.PHONY: test
test:
	ln -s $(MLINK) || true
	lein test

.PHONY:	testserv
testserv:
	wget -q -O - 'http://localhost:8080/parse?utterance=My+name+is+Paul+Landes&pretty=true'

.PHONY: dockerdist
dockerdist:	$(DOCKER_PREFIX)

.PHONY: prepare-docker
prepare-docker:
	@if [ -z "$(ZMODEL)" ] ; then \
		echo "missing zensol model dependency" ; \
		false ; \
	fi
	mkdir -p $(DOCKER_PREFIX)
	cp -r $(DIST_PREFIX)/$(APP_NAME_REF) $(DOCKER_PREFIX)
	cp src/docker/Dockerfile $(DOCKER_PREFIX)
	cp src/docker/$(ASBIN_NAME) $(DOCKER_PREFIX)/$(APP_SNAME_REF)/$(DIST_BIN_DNAME)
	cp -r $(ZMODEL) $(DOCKER_PREFIX)

$(DOCKER_PREFIX):	prepare-docker
#$(DOCKER_PREFIX):	$(DIST_BIN_DIR) prepare-docker
	docker rmi $(DOCKER_IMG_NAME) || true
	docker build -t $(DOCKER_IMG_NAME) $(DOCKER_PREFIX)

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
