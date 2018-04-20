## makefile automates the build and deployment for lein projects

PROJ_TYPE=		clojure
PROJ_MODULES=		model dist docker
APP_NAME=		nlparse
APP_SCR_NAME=		$(APP_NAME)
DOCKER_START_SCR=	src/sh/nlparsectrl
ZMODEL ?=		$(HOME)/opt/nlp/$(ZMODEL_NAME)
ZMODEL_TARG=		$(DOCKER_IMG_PREFIX)/model
DOCKER_IMG_NAME=	nlpservice
DOCKER_OBJS ?=		$(ZMODEL_TARG)

# make build dependencies
_ :=	$(shell [ ! -d .git ] && git init ; [ ! -d zenbuild ] && \
	  git submodule add https://github.com/plandes/zenbuild && make gitinit )

include ./zenbuild/main.mk

$(ZMODEL_TARG):
	@if [ -z "$(ZMODEL)" ] ; then \
		echo "missing zensol model dependency" ; \
		false ; \
	fi
	cp -r $(ZMODEL) $(DOCKER_IMG_PREFIX)

.PHONY:	testserv
testserv:
	wget -q -O - 'http://localhost:9100/parse?utterance=My+name+is+Paul+Landes&pretty=true'
