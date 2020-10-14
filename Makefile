volumes:
	docker volume create managair-data

fixtures:
	docker exec -it clair_backend_managair_server_1 python3 manage.py loaddata user_manager/fixtures/user-fixtures.json
	docker exec -it clair_backend_managair_server_1 python3 manage.py loaddata core/fixtures/device-fixtures.json
	docker exec -it clair_backend_managair_server_1 python3 manage.py loaddata core/fixtures/site-fixtures.json
	docker exec -it clair_backend_managair_server_1 python3 manage.py loaddata core/fixtures/data-fixtures.json

up:
	docker-compose -f clair_base-stack.yaml -f dev-stack.yaml up -d

down:
	docker-compose -f clair_base-stack.yaml -f dev-stack.yaml down

