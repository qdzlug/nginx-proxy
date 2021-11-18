.SILENT :
.PHONY : test-debian test-alpine test build-nginxplus build-nginxproxy


build-nginxplus:
	docker build -t nginxplus nplus/

build-nginxproxy: build-nginxplus
	docker build -t nginx-proxy .

build-webserver:
	docker build -t web test/requirements/web

build-nginx-proxy-test-debian:
	docker build -t nginxproxy/nginx-proxy:test .

build-nginx-proxy-test-alpine:
	docker build -f Dockerfile.alpine -t nginxproxy/nginx-proxy:test .

test-debian: build-webserver build-nginx-proxy-test-debian
	test/pytest.sh

test-alpine: build-webserver build-nginx-proxy-test-alpine
	test/pytest.sh

test: test-debian test-alpine
