.SILENT :
.PHONY : test-debian test-alpine test build-nginxplus build-nginxproxy

help: 
	@echo "Makefile commands:"
	@echo "build-nginxplus"
	@echo "build-nginxproxy"
	@echo "all"
	@echo ""
	@echo "NOTE: You need DOCKER_BUILDKIT enabled to build these images"

.DEFAULT_GOAL := build-nginxproxy


build-nginxplus:
	export DOCKER_BUILDKIT=1&&docker build --no-cache -t nginxplus --secret id=nginx-crt,src=nplus/nginx-repo.crt --secret id=nginx-key,src=nplus/nginx-repo.key ./nplus

build-nginxproxy: build-nginxplus
	export DOCKER_BUILDKIT=1&&docker build -t nginx-proxy . 

# Test functinality does not currently work.
#build-webserver:
	#docker build -t web test/requirements/web
#
#build-nginx-proxy-test-debian:
	#docker build -t nginxproxy/nginx-proxy:test .
#
#build-nginx-proxy-test-alpine:
	#docker build -f Dockerfile.alpine -t nginxproxy/nginx-proxy:test .
#
#test-debian: build-webserver build-nginx-proxy-test-debian
	#test/pytest.sh
#
#test-alpine: build-webserver build-nginx-proxy-test-alpine
	#test/pytest.sh
#
#test: test-debian test-alpine
