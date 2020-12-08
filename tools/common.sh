# common shell variables and functions

SCRIPT_NAME=`basename $0`
SCRIPT_DIR=`dirname $0`

COMPOSE_FILES_DIR="$SCRIPT_DIR/.."

REQUIRED_ENV_VARS="DOCKER_CONTEXT CLAIR_DOMAIN"

CLAIR_STACK_NAME=clair

# make the script fail if any command fails
set -e

fail () {
  msg=$1
  test -n "$msg" && echo -e "error: $msg"
  exit 1
}

# use usage function if defined
fail_usage () {
  msg=$1
  test -n "$msg" && echo -e "error: $msg"
  type usage &> /dev/null && usage || echo "usage: $SCRIPT_NAME env_file"
  exit 1
}

source_env_or_fail () {
  env_file=$1
  test -n "$env_file" || fail_usage "no env_file specified"
  test -f $env_file || fail_usage "$env_file is not a file"

  echo "environment file: $env_file"

  . $env_file

  for v in $REQUIRED_ENV_VARS; do
    test -n "${!v}" || fail "missing environment variable: $v"
    echo "$v: ${!v}"
  done
}

confirm_if_not_default () {
  test -n "$DOCKER_CONTEXT" || fail "DOCKER_CONTEXT undefined"
  test "$DOCKER_CONTEXT" = "default" && return
  read -p "docker context is $DOCKER_CONTEXT, type 'yes' to proceed: " answer
  test "$answer" = "yes" || exit
}

reset_docker_context () {
  docker context use default > /dev/null 2>&1
}

eval_in_docker_context () {
  test -n "$DOCKER_CONTEXT" || fail "DOCKER_CONTEXT undefined"
  docker context use $DOCKER_CONTEXT > /dev/null 2>&1
  trap reset_docker_context SIGINT
  eval $*
  reset_docker_context
}

find_managair_or_fail () {
  MANAGAIR_CONTAINER_ID=`eval_in_docker_context docker ps -qf "name=${CLAIR_STACK_NAME}_managair_server"`
  test -n "$MANAGAIR_CONTAINER_ID" || fail "managair container not found"
}
