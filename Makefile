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
		| tee dist/cluster.yaml
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

assets/eksctl: assets/eksctl_Darwin_x86_64.tar.gz \
               assets/eksctl_Linux_x86_64.tar.gz
assets/eksctl:
	: ## $@
	ls -lhat assets/eksctl*

assets/eksctl_Darwin_x86_64.tar.gz:
	: ## $@
	curl "https://github.com/eksctl-io/eksctl/releases/download/v0.183.0/eksctl_Darwin_amd64.tar.gz" \
     -L \
     -D/dev/stderr \
		 -o $@
assets/eksctl_Linux_x86_64.tar.gz:
	: ## $@
	curl "https://github.com/eksctl-io/eksctl/releases/download/v0.183.0/eksctl_Linux_amd64.tar.gz" \
     -L \
     -D/dev/stderr \
		 -o $@




