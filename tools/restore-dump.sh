#!/usr/bin/env bash

ROOT_DIR=`dirname $0`
. $ROOT_DIR/common.sh

usage() {
  echo "usage: $SCRIPT_NAME env_file dump_file"
}

dump_db () {
  dump_file=$1
  test -f "$dump_file" || fail_usage "no dump file specified"
  test -n "$SQL_DATABASE" || fail "SQL_DATABASE not set in environment file"
  test -n "$SQL_USER" || fail "SQL_USER not set in environment file"
  test -n "$SQL_PASSWORD" || fail "SQL_PASSWORD not set in environment file"
  DB_CONTAINER_ID=`eval_in_docker_context docker ps -qf "name=${CLAIR_STACK_NAME}_db"`
  test -n "$DB_CONTAINER_ID" || fail "db container not found"
  docker service scale clair_managair_server=0 clair_ingestair=0
  docker exec -e PGPASSWORD=$SQL_PASSWORD $DB_CONTAINER_ID psql -U $SQL_USER -d postgres -c "DROP DATABASE $SQL_DATABASE;" 
  docker exec -e PGPASSWORD=$SQL_PASSWORD $DB_CONTAINER_ID psql -U $SQL_USER -d postgres -c "CREATE DATABASE $SQL_DATABASE;" 
  docker exec -i $DB_CONTAINER_ID /bin/bash -c "PGPASSWORD=$SQL_PASSWORD psql -U $SQL_USER $SQL_DATABASE" < $dump_file
  docker service scale clair_managair_server=1 clair_ingestair=1
}

source_env_or_fail $1
confirm_if_not_default
shift
eval_in_docker_context dump_db $*
