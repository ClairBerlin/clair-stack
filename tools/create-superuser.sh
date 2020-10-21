#!/bin/bash

ROOT_DIR=`dirname $0`
. $ROOT_DIR/common.sh

create_superuser () {
  docker exec -it $MANAGAIR_CONTAINER_ID python3 manage.py createsuperuser
}

source_env_or_fail $1
eval_in_docker_context create_superuser
