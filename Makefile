THRIFT = $(or $(shell which thrift), $(error "`thrift' executable missing"))
REBAR = $(shell which rebar3 2>/dev/null || which ./rebar3)
SUBMODULES = build_utils
SUBTARGETS = $(patsubst %,%/.git,$(SUBMODULES))

UTILS_PATH := build_utils
TEMPLATES_PATH := .

# Name of the service
SERVICE_NAME := identdocstore-proto

# Build image tag to be used
BUILD_IMAGE_TAG := 07d3946f8f005782697de20270ac58cdcd18b011
CALL_ANYWHERE := \
	all submodules compile clean distclean \
	java_compile java_deploy deploy_nexus deploy_epic_nexus java_install

CALL_W_CONTAINER := $(CALL_ANYWHERE)

all: compile

-include $(UTILS_PATH)/make_lib/utils_container.mk

.PHONY: $(CALL_W_CONTAINER)

# CALL_ANYWHERE
$(SUBTARGETS): %/.git: %
	git submodule update --init $<
	touch $@

submodules: $(SUBTARGETS)

compile:
	$(REBAR) compile

clean:
	$(REBAR) clean

distclean:
	$(REBAR) clean -a
	rm -rfv _build

# Java

ifdef SETTINGS_XML
DOCKER_RUN_OPTS = -v $(SETTINGS_XML):$(SETTINGS_XML)
DOCKER_RUN_OPTS += -e SETTINGS_XML=$(SETTINGS_XML)
endif

ifdef LOCAL_BUILD
DOCKER_RUN_OPTS += -v $$HOME/.m2:/home/$(UNAME)/.m2:rw
endif

COMMIT_HASH = $(shell git --no-pager log -1 --pretty=format:"%h")
NUMBER_COMMITS = $(shell git rev-list --count HEAD)

java_compile:
	$(if $(SETTINGS_XML),,echo "SETTINGS_XML not defined" ; exit 1)
	mvn compile -s $(SETTINGS_XML)

deploy_nexus:
	$(if $(SETTINGS_XML),, echo "SETTINGS_XML not defined"; exit 1)
	mvn versions:set versions:commit -DnewVersion="1.$(NUMBER_COMMITS)-$(COMMIT_HASH)" -s $(SETTINGS_XML) \
	&& mvn deploy -s $(SETTINGS_XML) -Dpath_to_thrift="$(THRIFT)" -Dcommit.number="$(NUMBER_COMMITS)"

deploy_epic_nexus:
	$(if $(SETTINGS_XML),, echo "SETTINGS_XML not defined"; exit 1)
	mvn versions:set versions:commit -DnewVersion="1.$(NUMBER_COMMITS)-$(COMMIT_HASH)-epic" -s $(SETTINGS_XML) \
	&& mvn deploy -s $(SETTINGS_XML) -Dpath_to_thrift="$(THRIFT)" -Dcommit.number="$(NUMBER_COMMITS)"


java_install:
	$(if $(SETTINGS_XML),, echo "SETTINGS_XML not defined"; exit 1)
	mvn clean -s $(SETTINGS_XML) && \
	mvn versions:set versions:commit -DnewVersion="1.$(NUMBER_COMMITS)-$(COMMIT_HASH)" -s $(SETTINGS_XML) \
	&& mvn install -s $(SETTINGS_XML) -Dpath_to_thrift="$(THRIFT)" -Dcommit.number="$(NUMBER_COMMITS)"
