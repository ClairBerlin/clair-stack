#!/usr/bin/env bash

ROOT_DIR=`dirname $0`
. $ROOT_DIR/common.sh

CLAIR_VOLUMES="managair-data"

create_clair_volumes () {
  for volume in $CLAIR_VOLUMES; do
    if docker volume inspect $volume > /dev/null 2>&1; then
      echo_stderr "volume $volume exists"
    else
      docker volume create $volume
    fi
  done
}

source_env_or_fail $1
confirm_if_not_default
eval_in_docker_context create_clair_volumes
