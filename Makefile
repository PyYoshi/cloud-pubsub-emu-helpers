ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
DIST_DIR := ${ROOT_DIR}/dist

clean:
	@ rm -rf ${DIST_DIR} && mkdir -p ${DIST_DIR}

build: clean build-creator

build-creator:
	@ cd ${ROOT_DIR}/cmd/creator \
		&& GOARCH=amd64 GOOS=linux go build -ldflags="-s -w" -o ${DIST_DIR}/cpubsubc \
		&& upx --best ${DIST_DIR}/cpubsubc

tests:
	@ ${ROOT_DIR}/tests.bash
