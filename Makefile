#!/usr/bin/make -f

base:
	docker build -t skpr/base:1.x base


nginx: base
	docker build -t skpr/nginx:1.x nginx
	docker build -t skpr/nginx:1.x-dev nginx/dev

nginx-exporter:
	docker build -t skpr/nginx-exporter:0.0.1 nginx-exporter

define build_php
	# Building production images.
	docker build --build-arg PHP_VERSION=${1} -t skpr/php:${1}-1.x php/base
	docker build --build-arg PHP_VERSION=${1} -t skpr/php-fpm:${1}-1.x php/fpm
	docker build --build-arg PHP_VERSION=${1} -t skpr/php-cli:${1}-1.x php/cli

	# Building dev images.
	docker build --build-arg PHP_VERSION=${1} --build-arg IMAGE=skpr/php-fpm:${1}-1.x -t skpr/php-fpm:${1}-1.x-dev php/dev
	docker build --build-arg PHP_VERSION=${1} --build-arg IMAGE=skpr/php-cli:${1}-1.x -t skpr/php-cli:${1}-1.x-dev php/dev

	# Building Xdebug images.
	docker build --build-arg PHP_VERSION=${1} --build-arg IMAGE=skpr/php-fpm:${1}-1.x-dev -t skpr/php-fpm:${1}-1.x-xdebug php/dev
	docker build --build-arg PHP_VERSION=${1} --build-arg IMAGE=skpr/php-cli:${1}-1.x-dev -t skpr/php-cli:${1}-1.x-xdebug php/dev
endef

define push_php
	# Pushing production images.
	docker push skpr/php:${1}-1.x
	docker push skpr/php-fpm:${1}-1.x
	docker push skpr/php-cli:${1}-1.x

	# Pushing dev images.
	docker push skpr/php-fpm:${1}-1.x-dev
	docker push skpr/php-cli:${1}-1.x-dev

	# Pushing Xdebug images.
	docker push skpr/php-fpm:${1}-1.x-xdebug
	docker push skpr/php-cli:${1}-1.x-xdebug
endef

php: base
	$(call build_php,7.1)
	$(call build_php,7.2)
	$(call build_php,7.3)

php-push:
	$(call push_php,7.1)
	$(call push_php,7.2)
	$(call push_php,7.3)

kubebuilder:
	docker build -t skpr/kubebuilder:v1.0.6 kubebuilder

fpm-exporter:
	docker build -t skpr/fpm-exporter:v1.0.0 fpm-exporter

fluentd-cloudwatchlogs:
	docker build -t skpr/fluentd-cloudwatchlogs:v0.0.1 fluentd/cloudwatchlogs

solr:
	docker build -t skpr/solr:init solr/init
	docker build --build-arg SOLR_VERSION=7.7-slim \
	             --build-arg SEARCH_API_SOLR_VERSION=3.x \
	             -t skpr/solr:7.x-3.x solr/7.x

.PHONY: *