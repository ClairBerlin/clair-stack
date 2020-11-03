#!/usr/bin/env bash

ROOT_DIR=`dirname $0`
. $ROOT_DIR/common.sh

usage () {
  echo "usage: $SCRIPT_NAME env_file service_name"
}

follow_logs () {
  service_name=$1
  test -n "$service_name" || fail_usage "no service_name specified"
  container_id=`docker ps -qf "name=${CLAIR_STACK_NAME}_$service_name"`
  existing_services=`docker service ls --format={{.Name}} | sed s/${CLAIR_STACK_NAME}_//`
  test -n "$container_id" || fail "service $service_name not found, existing services:\n$existing_services"
  docker logs $container_id -f
}

source_env_or_fail $1
shift
eval_in_docker_context follow_logs $1
