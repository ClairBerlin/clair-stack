#!/bin/bash

ROOT_DIR=`dirname $0`
. $ROOT_DIR/common.sh

usage () {
  echo "usage: $SCRIPT_NAME [-y] arg..."
  echo "-y: skip confirmation"
}

manage_py () {
  docker exec -i $MANAGAIR_CONTAINER_ID python3 manage.py $@
}

source_env_or_fail $1
shift
find_managair_or_fail
if test "$1" = "-y"; then
  shift
else
  confirm_if_not_default
fi
eval_in_docker_context manage_py $@
