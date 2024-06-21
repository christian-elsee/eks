.DEFAULT_GOAL := all
.SHELLFLAGS := -euo pipefail $(if $(TRACE),-x,) -c
.ONESHELL:
.DELETE_ON_ERROR:

## env ##########################################
export NAME := $(shell basename $(PWD))
export PATH := dist/bin:$(PATH)

## interface ####################################
all: distclean dist build check
install: 

## main #########################################
distclean:
	: ## $@
	rm -rf dist

dist:
	: ## $@
	mkdir -p $@ $@/bin
	tar -xf assets/eksctl_$(shell uname -s)_$(shell uname -m).tar.gz \
		  -C  $@/bin

build: OVERLAYS ?=
build: base.yaml
	: ## $@
	cat $< $(OVERLAYS) \
		| yq --yaml-output --explicit-start -s add \
		| tee dist/cluster.yaml \
		| md5sum \
		| cut -f1 -d" " \
		| tee dist/checksum

	{ eksctl create cluster \
			--dry-run \
			-f dist/cluster.yaml \
		| tee /dev/fd/100 \
		| sed -E 's/Assume[^:]*\:\s*//' \
				>dist/plan.yaml \
	;} 100>&1

check: dist/plan.yaml
	: ## $@
	<$< yq --yaml-output --explicit-start -re .

install: dist/plan.yaml
	: ## $@
	eksctl create cluster \
		-f $< \
		--kubeconfig dist/config \
		--write-kubeconfig=true

assets: assets.yaml
	: ## $@
	mkdir -p $@

	<$< yq -re -re 'to_entries[] | "\(.key) \(.value)"' \
		| grep -Ei -- $(shell uname -s) \
		| xargs -rt -n2 -- sh -c '\
			curl "$$2" \
				-s \
		    -L \
		    -D/dev/stderr \
				-o $$1' _
