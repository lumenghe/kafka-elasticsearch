# -*- mode: makefile -*-

DOCKER = docker
COMPOSE = docker-compose -p kafka-elasticsearch
MAKE = make
UNAME_S := $(shell uname -s)
KZH_UTILS_BIN = utilities/bin

SUBMODULES = $(sort $(dir $(wildcard ./*lumenghe*/)))
SERVICES = $(sort $(dir $(wildcard ./*lumenghe*/)))


define udpate-master
  update-all-to-master:: ; cd $1 && git checkout -f master && git pull
endef

$(foreach dir,$(SUBMODULES),$(eval $(call udpate-master,$(dir))))


$(foreach dir,$(SERVICES),$(eval $(call alfred-everythings,$(dir))))


.PHONY: compile-kafka-smt
compile-kafka-smt:
	$(COMPOSE) run compile-kafka-smt


.PHONY: compile-ksqldb-udf
compile-ksqldb-udf:
	$(COMPOSE) run compile-ksqldb-udf


.PHONY: import-legacy-fixtures
import-legacy-fixtures:
	$(COMPOSE) run import-legacy-fixtures


.PHONY: build
build:
	$(COMPOSE) build
	$(MAKE) compile-kafka-smt
	$(MAKE) compile-ksqldb-udf
	$(MAKE) import-legacy-fixtures


.PHONY: run
run:
	$(COMPOSE) up --build -d kafka-connect kafka-hq elasticsearch kibana consul ksqldb-server ksqldb-cli

.PHONY: down
down:
	$(COMPOSE) down --volumes

.PHONY: format
format:
	$(COMPOSE) build format-imports
	$(COMPOSE) run format-imports
	$(COMPOSE) build format
	$(COMPOSE) run format


.PHONY: check-format
check-format:
	$(COMPOSE) build check-format-imports
	$(COMPOSE) run check-format-imports
	$(COMPOSE) build check-format
	$(COMPOSE) run check-format


.PHONY: style
style: check-format
	$(COMPOSE) build style
	$(COMPOSE) run style


.PHONY: complexity
complexity:
	$(COMPOSE) build complexity
	$(COMPOSE) run complexity

.PHONY: security-sast
security-sast:
	$(COMPOSE) build security-sast
	$(COMPOSE) run security-sast
