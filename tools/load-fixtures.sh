#!/usr/bin/env bash

ROOT_DIR=`dirname $0`
. $ROOT_DIR/common.sh

VALID_FIXTURES="core/fixtures/user-fixtures.json core/fixtures/inventory-fixtures.json core/fixtures/data-fixtures.json"

usage () {
  echo "usage: $SCRIPT_NAME env_file [fixture]..."
  echo "if no fixture is specified, all fixtures will be loaded"
  echo "valid fixtures are:"
  for f in $VALID_FIXTURES; do
    echo $f
  done
}

load_fixtures () {
  fixtures=${*:-$VALID_FIXTURES}
  for fixture in $fixtures; do
    echo "loading $fixture"
	  docker exec -it $MANAGAIR_CONTAINER_ID python3 manage.py loaddata $fixture
  done
}

source_env_or_fail $1
confirm_if_not_default
find_managair_or_fail
shift
eval_in_docker_context load_fixtures $*
