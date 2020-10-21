#!/bin/bash

ROOT_DIR=`dirname $0`
. $ROOT_DIR/common.sh

deploy_stack () {
  docker login
  docker stack deploy -c $COMPOSE_FILES_DIR/docker-compose.yml $DOCKER_STACK_DEPLOY_ARGS --with-registry-auth $CLAIR_STACK_NAME
}

source_env_or_fail $1
confirm_if_not_default
eval_in_docker_context deploy_stack
