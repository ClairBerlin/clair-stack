#!/bin/bash

ROOT_DIR=`dirname $0`
. $ROOT_DIR/common.sh

start_job_queue () {
	docker exec -it $MANAGAIR_CONTAINER_ID python3 manage.py qcluster
}

source_env_or_fail $1
eval_in_docker_context start_job_queue
