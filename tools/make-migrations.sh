#!/bin/bash

ROOT_DIR=`dirname $0`
. $ROOT_DIR/common.sh

make_migrations () {
	docker exec -it $MANAGAIR_CONTAINER_ID python3 manage.py makemigrations user_manager
	docker exec -it $MANAGAIR_CONTAINER_ID python3 manage.py makemigrations core
	docker exec -it $MANAGAIR_CONTAINER_ID python3 manage.py makemigrations ingest
}

source_env_or_fail $1
find_managair_or_fail
confirm_if_not_default
eval_in_docker_context make_migrations
