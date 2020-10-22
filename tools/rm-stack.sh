#!/usr/bin/env bash

ROOT_DIR=`dirname $0`
. $ROOT_DIR/common.sh

rm_stack () {
  docker stack rm $CLAIR_STACK_NAME
  while true; do
    echo "waiting for $CLAIR_STACK_NAME services to stop..."
    docker ps --filter name=$CLAIR_STACK_NAME | grep -q $CLAIR_STACK_NAME || break
    sleep 1
  done
  echo "done"
}

source_env_or_fail $1
confirm_if_not_default
eval_in_docker_context rm_stack
