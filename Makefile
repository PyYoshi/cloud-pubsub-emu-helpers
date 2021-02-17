ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
DIST_DIR := ${ROOT_DIR}/dist

clean:
	@ rm -rf ${DIST_DIR} && mkdir -p ${DIST_DIR}

build: clean build-creator build-archive

build-creator:
	@ cd ${ROOT_DIR}/cmd/creator \
		&& GOARCH=amd64 GOOS=linux go build -ldflags="-s -w" -o ${DIST_DIR}/cpubsubc \
		&& upx --best ${DIST_DIR}/cpubsubc

build-archive:
	@ cp ${ROOT_DIR}/LICENSE ${DIST_DIR}/ \
		&& cd ${DIST_DIR}/ \
		&& tar czf ${DIST_DIR}/cpubsubc-Linux-x86_64.tar.gz LICENSE cpubsubc \
		&& sha512sum cpubsubc-Linux-x86_64.tar.gz > ${DIST_DIR}/cpubsubc-Linux-x86_64.sha512sum

tests:
	@ ${ROOT_DIR}/tests.bash
