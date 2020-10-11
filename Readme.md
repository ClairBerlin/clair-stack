# The Clair Backend Infrastructure

This repository contains the [docker](https://www.docker.com) setup and all configuration necessary to deploy and run the entire Clair backend. Furthermore, this repository includes git submodules for individual applications of the Clair backend, to provide for a seamless development experience.

Our goal with the present infrastructure setup is to minimize the difference between development, staging, and production environments.

## Development setup

The Clair backend consists of several Python applications, some of which share a [PostgreSQL](https://www.postgresql.org) DBMS. For ease of development, we packaged the applications proper, the DBMS and the [pgAdmin](https://www.pgadmin.org) database administration service into docker containers, so that the entire setup can be run locally via `docker-compose`.

_TODO: Describe Docker Swarm setup._

### Preparing for first launch

To set up the Clair backend for development on your local machine, proceed as follows.

1. Install [docker](https://www.docker.com/get-started)
2. Clone the present repository onto your local machine. Make sure to include all git submodules. In the following, we assume that the _clair_backend_ repository is available at `<home>/codebase/clair_backend`. Change into this project root folder.
3. A default user and password for the DBMS is set in the compose file `dev-stack.yaml` via the environment variables `POSTGRES_USER` and `POSTGRES_PASSWORD`. Change them if you want to. Similarly, the default user (`PGADMIN_DEFAULT_EMAIL`) and password (`PGADMIN_DEFAULT_PASSWORD`) for logging into `pgAdmin` can be changed here.
4. Create the [named volume](https://docs.docker.com/storage/volumes/) to store the database: `docker volume create managair-data`
5. Run `docker-compose -f dev-stack.yaml up -d --build` to get started.

The entire backend stack will launch in DEVELOPMENT mode. Pending database migrations will be executed automatically.

There is a test dataset available that you can use to get started. To import it, execute `./managair/dev_utils/import_fixtures.sh`

## Development tasks

### General docker development commands

To inspect the application logs, use `docker logs managair_server -f`. This will follow the log as it is being written.

Because the application runs inside the container, all Django management commands must be executed _inside_ the container. That is, to execute `python3 manage.py <command>`, you need to pass the command though docker exec as `docker exec -it managair_server python3 manage.py <command>`.

### Managair application

The `managair_server` application is a Django web application. In DEVELOPMENT mode, it is executed in its internal development webserver, which supports hot reloads upon code changes. To this end, the local codebase is bind-mounted into the application's docker container. Whenever you make changes to code in the `managair` git submodule locally, it will trigger a restart of the application inside the container. 

All `managair` endpoints are available on your local machine at `localhost:8888`:

- To log in from a local webbrowser, open the preliminary login site at `localhost:8888/dashboard`.
- The [Django admin UI](https://docs.djangoproject.com/en/3.1/ref/contrib/admin/) is available at `localhost:8888/admin`. If you preloaded the test data, you can log in as user `admin` with password `admin`.
- The [browsable ReST API](https://www.django-rest-framework.org/topics/browsable-api/) is available at `localhost/api/<usecase>/v1/`, where `<usecase>` is one of `devices`, `sites`, or `data`.

When you preloaded the test data set, an admin user is already in place. If you want to create additional admin users, you can do so either via the _admin UI_ or by executing

`docker exec -it managair_server python3 manage.py createsuperuser`

Enter a username and password when requested. Open up the admin UI at `localhost:8888/admin` and check if you can log in with the admin credentials just set up.

### Database administration

To directly inspect and access the PostgreSQL database, a [pgAdmin](https://www.pgadmin.org) container is included in the stack. You can access it's UI at `localhost:8889`. Login as user `admin@admin.org`, with password `admin`.

Whenever you change or add models in the `managair_server` application, you need to create migration scripts as follows:

`docker exec -it managair_server python3 manage.py makemigrations <django_app>`

Here, `<django_app>` is the Django _app_ to which the new or updated models pertain; e.g. `device_manager`. Once the migrations scripts are in place, you can apply them either by restarting the `managair_server` via

`docker-compose -f dev-stack.yaml restart managair_server`,

or you can apply them on the fly via

`docker exec -it managair_server python3 manage.py migrate`.

## Services

## Traefik reverse proxy

TODO

### Managair core application

### Ingestair node data ingestion

### PostgreSQL DBMS

## Endpoints

- `/api/devices/v1/` provides ReST resources to administer individual nodes and information about node models from different manufacturers. Site-operators can register new nodes here.
- `api/sites/v1/` allows site-operators to administer their own sites and to associate nodes with locations.
- `api/data/v1/` provides read access to time series and individual measurements.

## References

- The docker setup closely follows [this guideline](https://testdriven.io/blog/dockerizing-django-with-postgres-gunicorn-and-nginx/) from [testdriven.io](https://testdriven.io/)
- To get started with basic Django concepts, have a look at [part 1](https://realpython.com/get-started-with-django-1/) of the Django tutorial from [RealPyhon](https://realpython.com/get-started-with-django-1/)
- Our user management is pretty much the [Django standard](https://docs.djangoproject.com/en/3.0/topics/auth/default/) authentication and authorization. See [part 2](https://realpython.com/django-user-management/) of the Django tutorial from [RealPython](https://realpython.com/) to get you started.
