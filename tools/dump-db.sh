#!/usr/bin/env bash

ROOT_DIR=`dirname $0`
. $ROOT_DIR/common.sh

dump_db () {
  test -n "$SQL_DATABASE" || fail "SQL_DATABASE not set in environment file"
  test -n "$SQL_USER" || fail "SQL_USER not set in environment file"
  test -n "$SQL_PASSWORD" || fail "SQL_PASSWORD not set in environment file"
  DB_CONTAINER_ID=`eval_in_docker_context docker ps -qf "name=${CLAIR_STACK_NAME}_db"`
  test -n "$DB_CONTAINER_ID" || fail "db container not found"
  docker exec -e PGPASSWORD=$SQL_PASSWORD $DB_CONTAINER_ID pg_dump -U $SQL_USER $SQL_DATABASE
}

source_env_or_fail $1
eval_in_docker_context dump_db
