#!/usr/bin/env bash

ROOT_DIR=`dirname $0`
. $ROOT_DIR/common.sh

deploy_composition () {
  docker-compose up -d -c $COMPOSE_FILES_DIR/docker-compose.yml $DOCKER_STACK_DEPLOY_ARGS --with-registry-auth $CLAIR_STACK_NAME
  while true; do
    echo_stderr "waiting for services to start..."
    docker image ls --filter name=$CLAIR_STACK_NAME --format {{.Replicas}} | grep -q 0 || break
    sleep 1
  done
  echo_stderr "done"
}

source_env_or_fail $1
deploy_composition
