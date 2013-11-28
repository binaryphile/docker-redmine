# Docker Redmine

Control scripts for a general-purpose Docker image of the Redmine issue
tracker.

## Requirements

- [Docker] version 0.6 or 0.7.

That's it.

## Quick Start - Development Mode

```
git clone git://github.com/binaryphile/docker-redmine
cd docker-redmine
cp sample.env .env
./initialize.sh
./redmine.sh
```

This will start a Redmine instance in development mode on port 3000 of
the host machine.  Connect at <http://localhost:3000/>.

To stop the server hit Ctrl-C.

## Quick Start - Production Mode

```
git clone git://github.com/binaryphile/docker-pgsql
cd docker-pgsql
cp sample.env .env
vim .env
```

Follow the directions in `.env`.  At a minimum, set:

- **SU_USER -** the superuser for the database cluster
- **SU_PASS -** the superuser password

```
./initialize.sh
./postgres.sh
cd ..
```

This will start a PostgreSQL server on the standard port (5432) on the
host.

If you've already done the development mode quick start, you can skip
these next few steps.

```
git clone git://github.com/binaryphile/docker-redmine
cd docker-redmine
cp sample.env .env
```

Pick up again here.  Make sure you're in the `docker-redmine` directory.

```
vim .env
```

Follow the directions in `.env`.  At a minimum, set:

- **SU_USER -** the superuser for the database cluster
- **SU_USER -** the superuser password
- **DB_USER -** the application user for the database
- **DB_PASS -** the application user password
- **RAILS_ENV -** set to `production`

```
./initialize.sh
./redmine.sh
```

This will start a Redmine instance in production mode on port 3001 of
the host machine.  Connect at <http://localhost:3001/>.

To stop the server run `docker stop $(docker ps -l -q)`.

To stop the PostgreSQL server, run `docker ps`, find the id of the
PostgreSQL container and run `docker stop [id]`.

## Installing Plugins

Put your plugins in the `plugins` directory under
`docker-redmine/2.3-stable` and run:

```
./migrate-plugins.sh
```

Note: _don't_ put plugins in their directory before you've run
`initialize.sh` or that command will fail.

## Installing Themes

Put your themes in the `themes` directory under
`docker-redmine/2.3-stable/public`.

## Upgrading

TBD

## Deploying

TBD

## Inbound Email

TBD

## Dockerfile

Instead of a conventional Dockerfile, there is a script
`dockerfile.sh` in the `dockerfile` directory.  I only mention this
since it's the first question anyone asks about the project.

You should only need the file if for some reason you need a different
version of Redmine.  If you're just looking to run Redmine server, I've
built this image so it can be customized with plugins and themes without
needing to be rebuilt.

If you run into a use case that isn't covered by my image, let me know
so that it can be improved.  By not having to rebuild the image it is
more likely to be reused by many people and for many to benefit by any
improvement in it.

If you _do_ need to rebuild the image, `dockerfile.sh` will generate an
image just like a regular Dockerfile.  I use shell script for two
reasons.  First, shell is more flexible and powerful than Dockerfiles.
Second, it is difficult to get Dockerfiles to stop generating a ton of
AUFS layers, and once you run out of layers, your image becomes
unusable.  So fewer is better.

For more details, see `README.md` in the `dockerfile` directory.

## Maintenance

When you run the server you are always creating a new container from the
image.  Periodically you will want to remove the stopped containers
which are leftover by using the command `docker rm $(docker ps -a -q)`.
Be careful, though, as this will remove all containers that aren't
running, so only use it if you don't have containers you're trying to
save.

If you do have ones you're saving, you can get around this by making
sure they are running when you run the rm command.  The rm command will
not delete containers which are currently running.

## MySQL Support

MySQL support hasn't been tested, but the image is built with the
prereqs.

Edit `.env` and set DB_ADAPTER to `mysql`.  You'll want to run
`initialize.sh` once in development mode so it can set up the host
(it'll set up a sqlite database as well, but that's ancillary).  After
that, switch RAILS_ENV to production so it will try to talk to MySQL
from then on.

You'll need to initialize the MySQL Redmine database yourself by
following the directions provided at the Redmine site.  You'll also have
to run the migrations and load default data by hand.

You can probably do this from your host machine without running a
container (assuming you have a working ruby environment).  However if
you need to run from the container, you can use the `bash.sh` script to
run an interactive shell inside.  The working directory will be mounted
as `/root`.

## Contents

Once installed, your image will have:

- Redmine 2.3-stable
- Rails 3.2.13
- Ruby 2.0.0-p247
- ImageMagick
- PostgreSQL adapter for production
- SQLite for development
- support for MySQL adapter
- Unicorn server for production
- Git and Mercurial binaries
- all gem requirements installed
- all binary requirements installed
- Ubuntu 12.04

The only things missing from a standard Redmine install are the extra
basic themes aside from the default theme.  You can install them as you
would any other theme.

## Container Stack

- binaryphile/redmine:2.3-stable
- binaryphile/redmine:2.3-prereqs
- binaryphile/ruby:2.0.0-p247
- ubuntu:12.04

## Directory Structure

- **2.3-stable/ - ** the Redmine 2.3 source repo, with Docker-friendly
customizations (cloned during `initialize.sh`)
- **dockerfile/ -** directory with image creation scripts - see
`README.md` in dir for details
- **scripts/ -** scripts which are run from inside the container
- **bash.sh -** start an interactive session inside a container
(development mode by default)
- **initialize.sh -** set up the Redmine source, bundler, extra
directories, the database and default data
- **migrate-plugins.sh -** bundle plugin gems and migrate plugins
- **sample.env -** sample values for important environment variables

## Description

The idea is to make it as simple as possible to deploy Redmine 2.3 on
any system which supports Docker.

The image is crafted so that you don't have to go inside of it.  All of
the lifecycle tasks can be done without opening a command shell inside
the container.

Not only that, the container itself is disposable.  No state or
configuration is kept inside the container.  Only the binary executables
are stored inside.  This means that you never restart a container with
the `docker start` command, instead you're always using the `docker run`
command in the form of one of the scripts in this project.

There are three basic usage models:

- production use only - you just want a Redmine server and maybe some
plugins and themes
- staging and production - like production use only but pilot-testing
new plugins in separate staging environment, perhaps your own desktop
- development and production use - you want to hack on plugin code or
the Redmine code itself

[Docker]: http://www.docker.io/

