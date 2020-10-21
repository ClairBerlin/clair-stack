#!/bin/bash

ROOT_DIR=`dirname $0`
. $ROOT_DIR/common.sh

manage_py () {
  docker exec -it $MANAGAIR_CONTAINER_ID python3 manage.py $*
}

source_env_or_fail $1
shift
find_managair_or_fail
confirm_if_not_default
eval_in_docker_context manage_py $*
