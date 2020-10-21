
#!/bin/bash

ROOT_DIR=`dirname $0`
. $ROOT_DIR/common.sh

regenerate_schema () {
	docker exec $MANAGAIR_CONTAINER_ID python3 manage.py spectacular --file schema.yamlx
}

source_env_or_fail $1
confirm_if_not_default
find_managair_or_fail
eval_in_docker_context regenerate_schema
