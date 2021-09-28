#!/usr/bin/env zsh

DB_POD=$(kubectl --namespace clair-berlin get pod -l app=db -o name)
DB_POD=${DB_POD#pod/}

kubectl --namespace clair-berlin exec $DB_POD -- pg_dump -U managair_dev managairdb_dev
