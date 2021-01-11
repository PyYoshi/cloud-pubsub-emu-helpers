#!/usr/bin/env bash

CONTAINER_IMAGE_NAME="pyyoshi/cloud-pubsub-helpers"
CONTAINER_PS_NAME="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)"

function dockerRun() {
  echo "Staring pub/sub emulator...: container=${CONTAINER_PS_NAME}"
  docker build -t ${CONTAINER_IMAGE_NAME} ./dockerfiles >/dev/null 2>&1
  docker run --rm --name "${CONTAINER_PS_NAME}" -p "8086:8086" -d -t ${CONTAINER_IMAGE_NAME} >/dev/null 2>&1
}

function test_creatorCmd() {
  PUBSUB_PROJECT="pj$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 16 | head -n 1)"
  PUBSUB_TOPIC="tp$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 16 | head -n 1)"
  PUBSUB_SUBSCRIPTION_1="sb$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 16 | head -n 1)"
  PUBSUB_SUBSCRIPTION_2="sb$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 16 | head -n 1)"

  printf "Test: cmd/creator: starting...\n"
  printf "\tPROJECT: %s\n" "${PUBSUB_PROJECT}"
  printf "\tTOPIC: %s\n" "${PUBSUB_TOPIC}"
  printf "\tPUBSUB_SUBSCRIPTION_1: %s\n" "${PUBSUB_SUBSCRIPTION_1}"
  printf "\tPUBSUB_SUBSCRIPTION_2: %s\n" "${PUBSUB_SUBSCRIPTION_2}"

  PUBSUB_EMULATOR_HOST="127.0.0.1:8086" go run ./cmd/creator/main.go -project "${PUBSUB_PROJECT}" \
                                                                     -topic "${PUBSUB_TOPIC}" \
                                                                     -subscription "${PUBSUB_SUBSCRIPTION_1}" \
                                                                     -subscription "${PUBSUB_SUBSCRIPTION_2}"
  testStatus=$?

  if [ ${testStatus} = 0 ]; then
    echo -e "\e[32mTest: cmd/creator: Successful!\e[m"
  else
    echo -e "\e[31mTest: cmd/creator: Failed!\e[m"
  fi

  return ${testStatus}
}

function dockerLogs() {
  docker logs "${CONTAINER_PS_NAME}"
}

function dockerStop() {
  echo "Shutting down pub/sub emulator...: container=${CONTAINER_PS_NAME}"
  docker stop "${CONTAINER_PS_NAME}" >/dev/null 2>&1
}

trap dockerStop EXIT

dockerRun
sleep 10s
test_creatorCmd
dockerLogs
exit $?
