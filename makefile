## makefile automates the build and deployment for lein projects

# edit these if you want
APP_NAME=		nlparse
APP_SCR_NAME=		$(APP_NAME)
APP_START_SCR=		src/sh/nlparsectrl
ZMODEL_NAME=		model
ZMODEL ?=		$(HOME)/opt/nlp/$(ZMODEL_NAME)
ZMODEL_TARG=		$(DOCKER_IMG_PREFIX)/$(ZMODEL_NAME)
DOCKER_IMG_NAME=	nlpservice
DOCKER_OBJS ?=		$(ZMODEL_TARG)

# location of the http://github.com/plandes/clj-zenbuild cloned directory
ZBHOME=			../clj-zenbuild

all:		dockerdist
	@echo "model: $(ZMODEL)"

include $(ZBHOME)/src/mk/compile.mk
include $(ZBHOME)/src/mk/model.mk
include $(ZBHOME)/src/mk/dist.mk
include $(ZBHOME)/src/mk/docker.mk

$(ZMODEL_TARG):
	@if [ -z "$(ZMODEL)" ] ; then \
		echo "missing zensol model dependency" ; \
		false ; \
	fi
	cp -r $(ZMODEL) $(DOCKER_IMG_PREFIX)

.PHONY:	testserv
testserv:
	wget -q -O - 'http://localhost:9100/parse?utterance=My+name+is+Paul+Landes&pretty=true'
