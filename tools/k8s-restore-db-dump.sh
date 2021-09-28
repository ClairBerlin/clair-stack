#!/usr/bin/env zsh

SQL_FILE=$1

if [ -z "$SQL_FILE" -o ! -f $SQL_FILE ]; then
	echo "file '$SQL_FILE' does not exist"
	exit 1
fi

function scale_db_deployments () {
	echo "scaling db deployments to $1"
	for deployment in ers-forwarder-v3 ers-forwarder-v2 clairchen-forwarder-v3 clairchen-forwarder-v2 ingestair managair-server; do
		kubectl --namespace clair-berlin scale deployment $deployment --replicas $1
	done
}

scale_db_deployments 0

DB_POD=$(kubectl --namespace clair-berlin get pod -l app=db -o name)
DB_POD=${DB_POD#pod/}

kubectl --namespace clair-berlin cp $SQL_FILE clair-berlin/$DB_POD:/tmp
kubectl --namespace clair-berlin exec $DB_POD -- dropdb -U managair_dev managairdb_dev
kubectl --namespace clair-berlin exec $DB_POD -- createdb -U managair_dev managairdb_dev
kubectl --namespace clair-berlin exec $DB_POD -- bash -c "psql -U managair_dev managairdb_dev < /tmp/$SQL_FILE"

scale_db_deployments 1
