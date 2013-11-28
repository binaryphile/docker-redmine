# Docker Redmine

Control scripts for a general-purpose Docker image for the Redmine issue
tracker.

# Requirements

- Docker version 0.6 or 0.7.

That's it.

# Quick Start - Development Mode

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

# Quick Start - Production Mode

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
the next few steps.

```
git clone git://github.com/binaryphile/docker-redmine
cd docker-redmine
cp sample.env .env
```

Pick up again here.  If you're pickup up here, make sure you're in the
`docker-redmine` directory.

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

# Installing Plugins

Put your plugins in the `plugins` directory under
`docker-redmine/2.3-stable` and run:

```
./migrate-plugins.sh
```

Note: _don't_ put plugins in their directory before you've run
`initialize.sh` or that command will fail.

# Installing Themes

Put your themes in the `themes` directory under
`docker-redmine/2.3-stable/public`.

# Dockerfile

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

# Contents

Once installed, your image will have:

- Redmine 2.3-stable
- Rails 3.2.13
- Ruby 2.0.0-p247
- ImageMagick
- PostgreSQL adapter for production
- SQLite for development
- support for MySQL adapter
- Git and Mercurial binaries
- all gem requirements installed
- all binary requirements installed

The only things missing from a standard Redmine install are the extra
basic themes aside from the default theme.  You can install them as you
would any other theme.

