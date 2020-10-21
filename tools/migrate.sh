#!/bin/bash

ROOT_DIR=`dirname $0`
. $ROOT_DIR/common.sh

migrate () {
	docker exec -it $MANAGAIR_CONTAINER_ID python3 manage.py migrate
}

source_env_or_fail $1
find_managair_or_fail
eval_in_docker_context migrate
