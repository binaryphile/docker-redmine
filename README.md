# Docker Redmine

Control scripts for a general-purpose Docker image of the [Redmine]
issue tracker.

## Requirements

- [Docker] version 0.6 or 0.7.

That's it.

## Quick Start - Development Mode

```
git clone git://github.com/binaryphile/docker-redmine
cd docker-redmine
./demo.sh
```

This will download, initialize and start a Redmine instance in
development mode on port 3000 of the host machine.  Connect at
<http://localhost:3000/>.

To stop the server hit Ctrl-C.  To restart the server in development
mode, run `redmine.sh` instead of `demo.sh`.

## Installing Plugins

Put your plugins in `docker-redmine/2.3-stable/plugins` and run:

```
./migrate-plugins.sh
```

Note: _don't_ put plugins in the directory before you've run `demo.sh`
(or `initialize.sh` for production) or that command will fail.

## Installing Themes

Put your themes in `docker-redmine/2.3-stable/public/themes` and restart
Redmine with `docker stop [id]` and `redmine.sh`.

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

Installing plugins and themes is the same as described above.

## Upgrading

TBD

## Deploying

TBD

## Inbound Email

TBD

## Contents

The image contains:

- Redmine 2.3-stable branch
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

The only things missing from the standard Redmine install are the extra
basic themes aside from the default theme.  You can install them as you
would any other theme.

## Image Stack

- binaryphile/redmine:2.3-stable
- binaryphile/redmine:2.3-prereqs
- binaryphile/ruby:2.0.0-p247
- ubuntu:12.04

## Directory Structure

- **2.3-stable/ -** the Redmine 2.3 source repo (cloned during
`initialize.sh`), with Docker-friendly customizations
- **dockerfile/ -** directory with image creation scripts - see
`README.md` in dir for details
- **scripts/ -** scripts which are run from inside the container
- **bash.sh -** start an interactive session inside a container
(development mode by default)
- **demo.sh -** do initial setup and run a development docker - use
`redmine.sh` instead after first run
- **initialize.sh -** set up the Redmine source, bundler, extra
directories, the database and default data
- **migrate-plugins.sh -** bundle plugin gems and migrate plugins
- **sample.env -** sample values for important environment variables

## Dockerfile

Instead of a conventional Dockerfile, there is a script `dockerfile.sh`
in the `dockerfile` directory.  It's written in bash for a few reasons,
mostly environment variable expansion, conditional execution and
single-layer generation of the image.

You should only need it if you need a different version of Redmine.  If
you're just looking to run Redmine as a server, you won't need to build
the image.  You can customize the existing image with plugins and themes
without a rebuild.

For more details, see `dockerfile/README.md`.

## Maintenance

When you run the server you are always creating a new container from the
image.  While most of the commands will automatically remove the
resulting container when stopped, Docker will not remove images which
were started with the daemon option, which is how production is run.  If
you're running production, periodically you will want to remove the
stopped containers which are left over.

You can do this using the command `docker rm $(docker ps -a -q)`.  Be
careful, though, as this will remove all containers that aren't running,
so only use it if you don't have containers you're trying to save.

If you do have stopped containers you're saving, you can get around this
by making sure they are running when you run the rm command.  The rm
command will not delete containers which are currently running.
Otherwise you will have to delete the stopped containers by id.

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

## Image Details

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

### Production

If you just want to run in production, follow the quick start
directions.  You'll need a real database system such as PostgreSQL.

Once you've cloned and started the server, it will be running on the
host port 3001.  It'll be running a [Unicorn] instance with 2 worker
processes.

You can set the number of worker processes in `.env` by setting
U_WORKERS.  You should not set this to less than 2.  Normally you'd want
to set it to the number of processors on your host.

Unicorn is an application server which isn't set up to serve static
assets when in production mode.  You should normally set up a reverse
proxy server which handles serving static assets and forwards other
requests to Unicorn.  You can find instructions for using Apache, nginx
or other servers by googling "Rails proxy server".

If you want to skip setting up a proxy and use Unicorn directly, you can
set RM_PORT to port 80 in `.env`.  You may need to configure the server
to serve static assets, although I haven't had to on mine, it just seems
to work.

### Staging

While you may simply set up a Redmine server and let it run, if you are
upgrading the machine periodically, you may want to stage a separate
server to ensure that the upgrade will work before you take down your
existing server.  You can do this on the same host as the production
server, but to avoid database conflicts, I recommend using a different
server so there is little chance you'll modify the production database.

The easiest way to set up a staging server is to stop the production
Redmine and PostgreSQL servers, then gzip the `docker-redmine` and
`docker-pgsql` directories and copy the files over to a new server (or
any system which supports Docker, such as a [Vagrant] box running on
your desktop).  Don't forget to restart the production servers,
PostgreSQL first.

Unzip both directories on the staging machine and run the PostgreSQL
server then upgrade Redmine and run it.  See the [Redmine] site for
details on upgrading.

### Development

If you're working on Redmine code itself or plugins, you can run a
container in development mode.  The image does not, however, provide a
development environment or tools, so it does not provide a lot of
benefit aside from providing a pre-setup Rails environment.

Still, it can be very convenient to use the container if you don't
already have a Rails development environment set up, since it has all of
the prerequisites.

I recommend setting up your tools, such as Vim or RubyMine, outside of
the container on the host.  The source is all kept outside the container
in the `2.3-stable` (or your branch name) directory, so you can edit it
there and keep a container running in development mode to test with a
web browser, since it runs from the same code on the host.

If you are working with a plugin, the standard image should work fine.
If you're working with your own fork of Redmine, however, you'll need to
make some modifications.

The image will work with any recent branch, so you can use it with your
own fork even if you aren't using 2.3-stable.  You just have to change
the GH_USER variable when you are setting up, and then make some
modifications to the Redmine code itself.  I've provided templates for
the files which need to change.

First edit `.env` and change GH_USER to your Github user id, or the one
which contains the Redmine fork if not yours.  The default is to use the
2.3-stable branch.  If you want a different -stable branch, set
RM_VERSION to the version number.  If instead you want a non-stable
branch, set RM_BRANCH.  For versions of Redmine which have the same
binary requirements as 2.3, you can leave RM_IMAGE alone.  Make sure
RAILS_ENV is unset, or set to development.

If there is a `2.3-stable` directory already, either move it or delete
it.  Once `.env` is properly set and there's no other source directory,
run `initialize.sh`.  This will clone the git repository and set up the
extra directories necessary to run.

Copy the files from `docker-redmine/templates` to your clone:

- database.yml - `docker-redmine/config/database.yml`
- Gemfile.local - `docker-redmine/Gemfile.local`
- sample.gitignore - `docker-redmine/.gitignore`
- unicorn.rb - `docker-redmine/config/unicorn.rb`

Commit the changes.

Run `initialize.sh` again to get the gems bundled.  Now you can run the
server with `redmine.sh` and your edits will show up when you test with
a web browser.  You can run the same code in production by committing
and pushing your changes, then making sure the production environment
pulls from the same github user and branch.

### File Ownership

The Redmine server in the container is run under the user "redmine".
This is the Linux user, as opposed to the database user.

When the Redmine process writes to the filesystem, it uses the uid
configured in the container.  From outside the container, the owner of
the files is the user on the host with the same uid.  This may or may
not be your account on the host, so if you have issues with file
ownership, you may need to build a custom image with a different uid for
the redmine user.

[Redmine]: http://www.redmine.org/
[Docker]: http://www.docker.io/
[Unicorn]: http://unicorn.bogomips.org/
[Vagrant]: http://www.vagrantup.com/

