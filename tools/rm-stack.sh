#!/bin/bash

ROOT_DIR=`dirname $0`
. $ROOT_DIR/common.sh

rm_stack () {
  docker stack rm $CLAIR_STACK_NAME
}

source_env_or_fail $1
confirm_if_not_default
eval_in_docker_context rm_stack
