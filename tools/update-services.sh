#!/usr/bin/env bash

ROOT_DIR=`dirname $0`
. $ROOT_DIR/common.sh

usage () {
  echo "usage: $SCRIPT_NAME env_file service_name..."
}

update_tasks () {
  test -n "$1" || fail_usage "no service_name specified"
  docker login
  for service_name in $*; do
    full_service_name=${CLAIR_STACK_NAME}_${service_name}
    image=`docker ps --filter "name=${full_service_name}" --format "{{.Image}}"`
    test -n "$image" || fail "service ${service_name} not found"
    docker pull $image
    docker service update --image $image $full_service_name
  done
}

source_env_or_fail $1
confirm_if_not_default
shift
eval_in_docker_context update_tasks $*
