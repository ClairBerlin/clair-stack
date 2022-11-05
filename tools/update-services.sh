#!/usr/bin/env bash

ROOT_DIR=`dirname $0`
. $ROOT_DIR/common.sh

usage () {
  echo_stderr "usage: $SCRIPT_NAME env_file [service_name image_name]..."
}

update_tasks () {
  while test "$#" != "0"; do
    service_name=$1
    image_name=$2
    test -n "$service_name" && test -n "$image_name" || fail_usage
    docker pull $image_name
    full_service_name=${CLAIR_STACK_NAME}_${service_name}
    docker service update --image $image_name $full_service_name --with-registry-auth
    shift 2
  done
}

source_env_or_fail $1
confirm_if_not_default
shift
eval_in_docker_context update_tasks $*
