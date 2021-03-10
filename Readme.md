# The Clair Backend Infrastructure

The _Clair Stack_ is the infrastructure-as-code implementation of the _Clair Platform_, a system to collect measurements from networked CO2-sensors for indoor air-quality monitoring. It is developed and run by the [Clair Berlin Initiative](https://clair-berlin.de), a non-profit, open-source initiative to help operators of public spaces lower the risk of SARS-CoV2-transmission amongst their patrons.

The Clair Stack consists of several Python applications, some of which share a [PostgreSQL](https://www.postgresql.org) DBMS. For ease of development, we packaged the applications proper, the DBMS, and the [pgAdmin](https://www.pgadmin.org) database administration service into docker containers, so that the entire setup can be run locally. Our goal with the present infrastructure setup is to minimize the difference between development, staging, production and other environments.

This repository contains the [docker](https://www.docker.com) setup and all configuration necessary to deploy and run the entire Clair Stack. Furthermore, this repository includes git submodules for individual applications of the stack, to provide for a seamless development experience.

We use docker in swarm mode, [docker contexts](https://docs.docker.com/engine/context/working-with-contexts/), and [`docker stack deploy`](https://docs.docker.com/engine/swarm/stack-deploy/) to deploy the stack defined in `docker-compose.yml` and its [extension files](https://docs.docker.com/compose/extends/) `docker-compose.X.yml`.

`docker-compose up` does not work with these docker-compose files because the [Traefik reverse proxy](https://doc.traefik.io/traefik/) we use reads its configuration from labels attached to the `deploy` sections of the services, which are ignored by `docker-compose`.

## Services

The Clair stack comprises the following services:

* `reverse_proxy`: [Traefik reverse proxy](https://doc.traefik.io/traefik/).
* `managair_server`: [Django](https://www.djangoproject.com/) application, business layer models, public API.
* `static_frontend`: An [nginx](https://nginx.org/) image that serves the [Clair frontend](https://github.com/ClairBerlin/clair-frontend).
* `ingestair`: A second instance of the managair container; provides an internal ingestion endpoint for measurement samples (potentially public in the future).
* `clairchen_forwarder`: A [TTN application](https://github.com/ClairBerlin/clair-ttn/) that receives uplink messages of Clairchen devices, decodes them, and forwards their samples to the `ingestair`.
* `ers_forwarder`: The same for ERS devices.
* `db`: The [PostgreSQL](https://www.postgresql.org/) database management system (DBMS).
* `redis`: A [redis](https://redis.io/) store, used by Django's task queue.

### Extensions

#### Development

The `docker-compose.dev.yml` extension used for the development environment adds the following service:

* `pgadmin`: A [pgAdmin](https://www.pgadmin.org/) instance to inspect and manipulate the databases.

#### TLS

The `docker-compose.tls.yml` extension adds Traefik labels to enable automatic TLS encryption (https) using [Let's Encrypt](https://letsencrypt.org/) (LE). This should only be enabled for swarms that can be accessed by the LE servers on the internet.

## Configuration via environments

All configuration is handled through environment variables. For each deployment target, all environment variables are grouped in a target-specific environment file located in the `environments/` folder. Upon deployment, the configuration of the Clair stack is sourced from the selected environment file.

The first three environment variables in each file control the overall deployment:

* `DOCKER_CONTEXT`: The [docker context](https://docs.docker.com/engine/context/working-with-contexts/) to use. The context defines the docker swarm on which the system is to be deployed. If you want to deploy teh stack for local development work, you need to initialize a local context first, which will typically be named `default`. Use `docker context ls` to see all available contexts.
* `CLAIR_DOMAIN`: The domain used by Traefik and Django to configure their routes (`localhost`, `clair-ev.de` or similar).
* `DOCKER_STACK_DEPLOY_ARGS`: Optinal additional arguments to `docker stack deply`, mainly used to add extension files; e.g., `DOCKER_STACK_DEPLOY_ARGS="-c docker-compose.dev.yml".

All remaining variables affect one or more services.

## Secrets

Some of the containers depend on various credentials; e.g., to access the TTN applications. We use [docker secrets](https://docs.docker.com/engine/swarm/secrets/) to securely transmit and store these credentials. All secrets are meant to be placed in files in the `secrets` subdirectory. The secrets in use can be found in the `secrets` sections of the `docker-compose(.X).yml` files.

The `secrets` subdirectory is ignored by git. **Never commit any secrets to a git repository!**

## Development setup

To set up the Clair backend for development on your local machine, proceed as follows:

1. Install [docker](https://www.docker.com/get-started)
2. Activate swarm mode:  
  `docker swarm init`
3. Clone the present repository onto your local machine:  
  `git clone git@github.com:ClairBerlin/clair-stack.git`
4. Check out the submodules ([learn more about git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)):  
  `git submodule init && git submodule update`
5. If your local docker context is not named `default`, and the local domain should be called differently than `localhost`, adjust the `DOCKER_CONTEXT` and `CLAIR_DOMAIN` environment variables in `environments/dev.env`
6. Create volumes:  
  `tools/create-volumes.sh environments/dev.env`
7. Deploy the development stack locally:  
  `tools/deploy-stack.sh environments/dev.env`
8. Load example data from fixtures:  
  `tools/load-fixtures.sh environments/dev.env`

The entire backend stack will launch in DEVELOPMENT mode. Pending database migrations will be executed automatically.

### Development access to the managair application

The `managair_server` application is a Django web application. In DEVELOPMENT mode, it is executed in its internal development webserver, which supports hot reloads upon code changes. To this end, the local codebase is bind-mounted into the application's docker container. Whenever you make changes to code in the `managair` git submodule locally, it will trigger a restart of the application inside the container.

All `managair` endpoints are available on your local machine at `localhost:8888`:

- To log in from a local webbrowser, open the preliminary login site at `localhost:8888/dashboard`.
- The [Django admin UI](https://docs.djangoproject.com/en/3.1/ref/contrib/admin/) is available at `localhost:8888/admin`. If you preloaded the test data, you can log in as user `admin` with password `admin`.
- The [browsable ReST API](https://www.django-rest-framework.org/topics/browsable-api/) is available at `localhost/api/v1/`.

### Development access to the database

To directly inspect and access the PostgreSQL database, a [pgAdmin](https://www.pgadmin.org) container is included in the stack. You can access its UI at `localhost:8889`. Login as user `admin@admin.org`, with password `admin`.

## Utilities

As long as no solid continuous deployment system is in place, we deploy manually using `docker context use X` and `docker stack deploy`.

Since there is a substantial risk of inadvertently causing damage by not resetting the docker context on your system, it is *highly recommended* to use the respective tool in the `tools` subdirectory. All these tools expect a valid environment file as their first (and usually only) argument, and warn you when you are about to make changes to a docker context that is not the default.

### Deployment Utilities

#### `deploy-stack.sh env`

Deploy the Clair stack to DOCKER_CONTEXT.

#### `rm-stack.sh env`

Remove the Clair stack from DOCKER_CONTEXT.

### Initial Setup Utilities

#### `create-volumes.sh env`

Create the external volumes used by the Clair stack.

#### `load-fixtures.sh env [fixture]...`

Load sample data from internal json files.

### Development Utilities

#### `manage-py.sh env [-y] arg...`

Access the
[`manage.py`](https://docs.djangoproject.com/en/3.1/ref/django-admin/) script
of the `managair_server` container. All arguments are passed on.

Add `-y` to skip confirmation in case of non-default docker contexts. This is needed for piping to stdin, as in loaddata (see below), since the prompt leads to a broken pipe.

Examples:

```bash
tools/manage-py.sh environments/dev.env createsuperuser
tools/manage-py.sh environments/dev.env makemigrations
```

### Miscellaneous

#### `follow-logs.sh env service`

Fetch and follow the log output for one of the stack's services:

```bash
tools/follow-logs.sh environments/livland.env managair_server
```

#### `sampledump2fixture.py dump.json`

Convert a mongo export of the obsolete ingestair database to a fixture which can be loaded from stdin.

```bash
docker exec -i clair_mongo.X.YYYYYY mongoexport --db clair --collection base_sample --jsonFormat canonical > samples_mongo.json

tools/sampledump2fixture.py samples_mongo.json | tools/manage-py.sh environments/livland.env -y loaddata --format=json -
```

## Administration

The following is a summary of typical administrative tasks for a production environment.

### Insert samples into the database

There might arise the need to add samples to the core database that were not present previously.
The simplest way to do so is via [Django fixtures](https://docs.djangoproject.com/en/3.1/howto/initial-data/).
Developed as a means to populate a Django database for testing, fixtures can also be used to load additional data into a table.

The most common administrative use for the Clair Stack arises when a [TTN forwarder] disconnects from the Things Network for any reason, so that sensor data no longer arrives at the Clair Stack.
If the corresponding TTN application has the [Data Storage Integration](https://www.thethingsnetwork.org/docs/applications/storage/index.html) enabled, it acts as a backup from which you can recover lost data for up to seven days.
Use the command line tool `clair-generate-fixtures-from-storage` that comes with the [Clair-TTN](https://github.com/ClairBerlin/clair-ttn) application to retrieve the missing samples from the TTN storage integration and turn them into a JSON file that can be read in as a Django fixture.

To otherwise import samples, you need to prepare them according to Django's fixture format.
To actually trigger the import, pipe the resulting fixtures file into the Django management wrapper discussed previously:

```bash
cat <fixtures_file> | ./tools/manage-py.sh -y <environment_file> loaddata --format=json -
```

Note that the `-y` flag overrides the safety question when you attempt to rund the command on a production environment. The trailing dash `-` is required for Django to pick up the stream from stdin.

Upon import, the DBMS enforces constraints on the uniqueness of samples - you cannot re-import a sample that is already present in the database. Therefore, you need to manually clean the fixtures in advances to not contain duplicates.

### Restart a single service

_TODO_

### Update a service

_TODO_

## References

- The docker setup closely follows [this guideline](https://testdriven.io/blog/dockerizing-django-with-postgres-gunicorn-and-nginx/) from [testdriven.io](https://testdriven.io/)
- To get started with basic Django concepts, have a look at [part 1](https://realpython.com/get-started-with-django-1/) of the Django tutorial from [RealPyhon](https://realpython.com/get-started-with-django-1/)
- Our user management is pretty much the [Django standard](https://docs.djangoproject.com/en/3.0/topics/auth/default/) authentication and authorization. See [part 2](https://realpython.com/django-user-management/) of the Django tutorial from [RealPython](https://realpython.com/) to get you started.
