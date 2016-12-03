## makefile automates the build and deployment for lein projects

# edit these if you want
APP_NAME=	nlparse
APP_SCR_NAME=	$(APP_NAME)

# location of the http://github.com/plandes/clj-zenbuild cloned directory
ZBHOME=		../clj-zenbuild

# where the stanford model files are located
#ZMODEL=		$(HOME)/opt/nlp/model

# clean the generated app assembly file
MLINK=		$(ZMODEL)
ADD_CLEAN+=	$(ASBIN_DIR) model

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
