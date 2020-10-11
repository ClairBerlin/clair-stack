# Managair - The Clair Management Interface

## Functionality

### User-Facing Services

- Register a new user, update a user's profile [rough sketch available].
- Register a sensor node, remove a sensor node [open].
- Add a location, associate sensor nodes with a location, update location information [open].
- Inspect and analyze measurement time-series and derived data [open].
- GDPR transparency: export personal data, delete an account and all associated data [open].

### Administrative Services

- User management: Register and update users. Change user permissions.
- Device management: Add and update node types [Available via the Django admin UI].
- System administration [Django admin UI]

## Development Setup

Managair is a [Django](https://www.djangoproject.com/) web application atop a [PostgreSQL](https://www.postgresql.org) DBMS. For ease of development, we packaged the application proper, the DBMS and the [pgAdmin](https://www.pgadmin.org) database administration service into docker containers, so that the entire setup can be run locally via `docker-compose`. To set up managair for development on your local machine, proceed as follows.

1. Install [docker](https://www.docker.com/get-started)
2. Clone the present repository onto your local machine. In the following, we assume that the _managair_ repository is available at `<home>/codebase/managair`. Change into this project root folder.
3. A default user and password for the DBMS is set in the compose file `dev-stack.yaml` via the environment variables `POSTGRES_USER` and `POSTGRES_PASSWORD`. Change them if you want to. Similarly, the default user (`PGADMIN_DEFAULT_EMAIL`) and password (`PGADMIN_DEFAULT_PASSWORD`) for logging into `pgAdmin` can be changed here.
4. Run `docker-compose -f dev-stack.yaml up -d --build` to get started.
5. Create the [named volume](https://docs.docker.com/storage/volumes/) to store the database: `docker volume create managair-data`
6. Open the source code in your editor of choice. The code in your root folder is bind-mounted into the application's docker container for quick edit-debug cycles.
7. Open `localhost:8888/dashboard` to see the application's web view.
8. Open `localhost:8889` to access the `pgAdmin` UI.

### Preparing for first launch

Before you can interact with the application, the database need to be set up. From a terminal in the repository root folder, issue the following commands:

1. `docker exec -it managair_server python3 manage.py makemigrations user_manager`
2. `docker exec -it managair_server python3 manage.py makemigrations device_manager`
3. `docker exec -it managair_server python3 manage.py migrate`
4. Finally, set up an admin user, which can be used to log into the Django admin UI: `docker exec -it managair_server python3 manage.py createsuperuser` Enter a username and password when requested.
5. Open up the admin interface at `localhost:8888/admin`and check if you can log in with the admin credentials just set up.

### Simplify development tasks

The `managair` application is running in development mode, with automatic reloads enabled. Whenever you make changes to the code and save them, the development webserver inside the docker container will restart the application.

To inspect the application logs, use `docker logs managair_server -f`. This will follow the log as it is being written.

Because the application runs inside the container, all Django management commands must be executed _inside_ the container - like the commands shown above. That is, to execute `python3 manage.py <command>`, you need to pass the command though docker exec as `docker exec -it managair_server python3 manage.py <command>`.

### Data fixtures

To start development work right away, it would be convenient if important data was preloaded into the DB already. This is what [Django fixtures](https://docs.djangoproject.com/en/3.1/howto/initial-data/) are for. Fixture files are JSON files that contain data in a format that can be directly importet into the DB. They are available for the individual applications in their `fixture` folders. To set up the the application for development, load the fixtures as follows:

- `docker exec -it managair_server python3 manage.py loaddata device_manager/fixtures/device-fixtures.json`
- `docker exec -it managair_server python3 manage.py loaddata ts_manager/fixtures/sample-fixtures.json`

Make sure to respect the order because of foreign-key constraints.

### Resources

- The docker setup closely follows [this guideline](https://testdriven.io/blog/dockerizing-django-with-postgres-gunicorn-and-nginx/) from [testdriven.io](https://testdriven.io/)
- To get started with basic Django concepts, have a look at [part 1](https://realpython.com/get-started-with-django-1/) of the Django tutorial from [RealPyhon](https://realpython.com/get-started-with-django-1/)
- Our user management is pretty much the [Django standard](https://docs.djangoproject.com/en/3.0/topics/auth/default/) authentication and authorization. See [part 2](https://realpython.com/django-user-management/) of the Django tutorial from [RealPython](https://realpython.com/) to get you started.
