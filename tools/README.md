Migrate Samples from Flask/Mongo to Django/Postgres
===================================================

```
docker context use clair-staging

docker exec -i clair_mongo.X.YYYYYY mongoexport --db clair --collection base_sample --jsonFormat canonical > samples_mongo.json

tools/sampledump2fixture.py samples_mongo.json | docker exec -i clair_managair_server.X.YYYYYY python3 manage.py loaddata --format=json -
```

