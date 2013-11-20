# Redmine Docker Image Control Scripts

There is a Redmine Docker image I created which is available on the
Docker index.  This repository contains scripts that let you start the
container with various configurations.

Features:

- Redmine 2.3 stable
- Use PostgreSQL or MySQL (adapters included but not the DBMS)
- ImageMagick, git, mercurial included
- Plugins do not require a rebuild of the image
- Credentials and environment are passed in and don't require rebuild
- Uses `docker run` exclusively, not `docker start`
- Container only includes necessary binary dependencies - source,
  attachments, plugins are kept on the host
- Container does not need to be running to work with the files
- No dev environment or ssh required in the container
- Container works for production or development

If you build a Docker container for a Rails app, it can be a good deal
more complex than a regular Docker container.  For example, you'd want
the same container to be able to run as a daemon or as an interactive
session, in development or production mode.  You might want it to talk
to different databases.  Databases involve credentials, and you can't
put a container on the index if it contains credentials.

To get around these issues, environment variables are set either in your
shell or in a project-specific `.env` file and fed into the container.
All of the desired behavior is configured through these variables.

Because environment variables can be annoying to deal with, I've made it
so they can be edited in a project-local file and fed into the container
without requiring you to type long, complex docker commands.

The goal is for you to be able to use Redmine without having to build
your own Redmine image.  Hence the things that make a Redmine instance
"yours", i.e. the plugins, file attachments, logs etc., are all kept
outside the image on your local filesystem.

The image is meant to be used as if Redmine had been "compiled" into an
executable (the image).  It's started and controlled from outside the
Docker container, on the host like an executable.  The container stores
no persistent state and there is usually no need for visibility inside
the container, just as executables do not store persistent state and do
not require visibility inside them.

There are scripts which allow you to:

- Run a quick demonstration of Redmine, running sqlite in development
mode with Webrick
- Set up the sqlite database with default data (required by the demo)
- Set up a production database with user credentials and default data
- Install your plugins, bundle their gems and run their migrations
- Run a production Redmine in daemon mode with unicorn
- Run an interactive bash session inside the container, useful for
troubleshooting

The structure is set up this way: (the scripts take care of all of this
for you):

- Ruby and all binary dependencies, including DB adapters and SCM
binaries are in the image
- The Redmine source, with my own modifications to allow environment
config, is downloaded into the host working directory and run from there
- Plugins, attachments etc all go in the host directory as well
- Gems are pre-bundled in the image, but are exported to your local
directory so plugins can install new gems

You can set up your own Redmine source (after customizing with my mods)
or build an image with different dependencies.  Look in the
`dockerfile` directory for more details.

This image builds off some of my other images which you might also find
interesting: on top of Docker's base ubuntu:precise, I have a Ruby 2.0
image (binaryphile/ruby:2.0.0-p247), then a Redmine binary dependency
image w/o the bundle (binaryphile/redmine:2.3-prereqs).

## Getting Started with a Demo (development mode)

First copy `sample.env` to `.env`.  If you aren't in the `docker` group,
uncomment the line containing `export SUDO=sudo`.

To run a demo of Redmine in development mode, run:

    ./initialize-development.sh
    ./demo.sh

Then point your browser to <http://localhost:3000/>.  Admin user is
"admin", password "admin".  You'll want to change this if the system is
on an untrusted network.  Port 3000 will be available to the general
local network unless you firewall it.

The container will run a development mode instance which will output to
the terminal just as if you had run `bundle exec rails s`.

To stop it, just hit Ctrl-C.

`initialize-development.sh` creates a sqlite database and initializes it
with the Redmine default data.  You only need to do this once.  The
database is created in this directory under `./redmine-2.3-stable/db`.

`demo.sh` runs Redmine in development mode if you want to start it up
again.

## Getting Started with Production

You'll need to have PostgreSQL already running on the local host and the
standard port (5432).  The server should exist but should not have a
redmine user or database yet.

If you haven't already, copy `sample.env` to `.env`.  If you're not in
the `docker` group, uncomment the line containing `export SUDO=sudo`.

Edit `.env` and set:

- **SU_USER** - the server superuser name
- **SU_PASS** - the server superuser password
- **DB_USER** - the redmine desired user name
- **DB_PASS** - the desired redmine user password

Then run:

    ./initialize-production.sh
    ./redmine.sh

Point a web browser at <http://localhost:3001/> to see the site in
action.  Since the image does not include a proxy server, you will need
to configure your own Apache/nginx/whatever to front the web server.

To stop it, run `docker stop $(docker ps -l)`.

`initialize-production.sh` will create the redmine user and database as
well as load the default Redmine data.

`redmine.sh` runs a production redmine instance in daemon mode in the
background.  There is no output to the terminal and the prompt returns
as soon as the container is started.

The web server is [unicorn] running with 2 worker processes by default.
To change the number of worker processes, edit `.env` and set
`U_WORKERS` to your desired number.

## Contents

The 2.3-stable image contains a vanilla (no plugins) Redmine 2.3-stable,
the latest at the time of this writing, running on Rails 3.5.13.

Ruby 2.0.0-p247 and all dependencies are included in the container, so
running it doesn't require any bundling or software installation.

The container is configured to put logs, Redmine file attachments and
the application's secret_token file on your local filesystem via
mounting the current directory in the container.  The files will be in
the directory `redmine-2.3-stable` under this one.

Plugins are mounted from the `redmine-2.3-stable/plugin` folder in this
directory.  Run `./install-plugins.sh` to rebundle and run plugin
migrations.  By default it will run the migrations in development mode,
so if you want them to run in production mode, set `export
RAILS_ENV=production` in the `.env` file _in the redmine-2.3-stable`
directory_.

The image includes git and mercurial SCM executables.  If you need
others you'll have to rebuild the image.

ImageMagick is installed.

The image includes all requirements for using PostgreSQL and MySQL in
production.  Development mode only supports sqlite.  If you need MSSQL
in production or anything other than sqlite in development, you'll have
to rebuild the image.

## Maintenance

Since Docker creates a new container from the image every time you start
Redmine, you may want to periodically clean them up.  The command
`docker rm $(docker ps -a -q)` will remove all non-running containers.
Use with caution if you run any other containers than Redmine on your
host.  Otherwise just use `docker rm [container id]` to remove
individual containers.

## Customization

Once you've gotten it working, you may want to do any of the following:

- Customize the Redmine source code
- Customize Redmine with static pages
- Customize Redmine with plugins
- Customize Redmine with themes

### Customize the Redmine Source Code

Any modifications you want to make to the Redmine source can be done in
`redmine-2.3-stable`.  Currently that folder is not under version
control, so the best approach is to fork either my 2.3-stable branch on
github, or the main Redmine repo's 2.3-stable branch.  Clone that
elsewhere, commit and push your modifications.  Copy your source to
`redmine-2.3-stable` and restart Redmine.

If you decide to fork the main Redmine repo, you'll need to replace the
files in your fork with the ones from `dockerfile/templates`.  These
allow the environment variables to control the configuration.  See
`dockerfile/README.md` for more info.

Also, if you decide to reinitialize your image, you'll want to modify
GH_USER in `.env` to point to your github username so it downloads your
fork of the Redmine source.

### Customize Redmine with Static Pages

Put any html files you want in `redmine-2.3-stable/public`.  I haven't
tested this yet, and it probably won't work in production mode, but it
should work in development.

### Customize Redmine with Plugins

Make sure your database has been initialized with one of the
initialization scripts.

Then your plugins to the plugins folder here and run
`./install-plugins.sh`.  It will run bundler and migrate the plugins.
This script is not well-tested at this point and may not work correctly.

It is recommended that you create a git repository in the plugins
directory which stores all of your plugins.  This will make it easier to
deploy in production.

### Customize Redmine with Themes

Install your theme in `redmine-2.3-stable/public/themes`.  You may need
to restart Redmine for it to become available in the Administration
settings.

## Production Deployment

### Clone This Repo

The first thing to do is to clone this repository to your production
machine, the Docker host.  Then copy `sample.env` to `.env`.  `.env`
already appears in the git ignores, so you won't check in any sensitive
information accidentally.

Edit `.env` and add your database superuser credentials as SU_NAME and
SU_PASS and your desired redmine user as DB_USER and DB_PASS.  The rest
of the variables can stay default.

### Initialize the Database

Follow the instructions above for setting up a PostgreSQL database,
which is mostly just running `initialize-production.sh`.  If you don't
have pg, you can use my PostgreSQL image from
<https://github.com/binaryphile/docker-pgsql>.

You can run with a MySQL database by changing the database adapter in
the `.env` file to `mysql`.  I haven't tried this and don't have any
further help for you there.

### Start Redmine

Run `redmine.sh` as in Getting Started.

Stop with `docker ps -l` and `docker stop [id]`.

### Deploy an Upgraded Image

If a new version of the image comes out, set the new version in `.env`
for `RM_IMAGE`.

Stop the old container. Then run `./migrate.sh`.

Start the new image with `redmine.sh`.

### Deploy New Plugins

Stop the old container, then pull your changes to the plugins folder.

Run `./migrate.sh` and `redmine.sh`.

### A Note on Unicorn

Unicorn is used for production because it easily allows multiple worker
processes to run behind a single application server port.

You can use the `.env` variable U_WORKERS to set the number of worker
processes.  Usually you'll want it set to the number of CPUs on the host
machine.  If not set explicitly it will default to 2 in my setup.  Even
if you have one processor, I suggest you have at least 2 worker
processes.

Containers make the hot-upgrade feature of unicorn useless, since you're
scrapping the entire container when you upgrade and unicorn is inside
it.  There isn't a comparable feature in my setup here, but you can
certainly investigate [hipache], which is the Docker company's project
for orchestrating container upgrades, among other features.

### Processing Incoming Emails Locally

Redmine has a rake task to process incoming emails through IMAP or POP3.

The same image can be used to run a separate container which processes
the emails and feeds them into your production database.  You can set up
a cron job like:

`*/10 * * * * docker run -d -v /path/to/redmine-2.3-stable:/root -w /root -e RAILS_ENV=production binaryphile/redmine:2.3-stable bundle exec rake redmine:email:receive_imap [the rest of the options]`

That will run the email task every 10 minutes.  Check `/var/log/syslog`
and `redmine-2.3-stable/log/production.log` for messages.  Choose the
`receive_imap` or `receive_pop3` task as appropriate.  Change the docker
path to point to your installation, and look up the rest of the rake
task's options on the Redmine wiki.

### Running a Proxy Server

If you want to run other websites from the same host or to run with SSL,
you'll want a proxy server such as Apache, nginx or even IIS to front
unicorn.  I don't have such a container made for you, nor do I have the
instructions on how to do so since that's a whole other ball of wax.

### Integrating the Containers as a Service on the Host

I also don't have instructions on how to integrate these containers into
the startup process on your host.  I'd suggest looking at [bluepill] or
[Monit].  Either of these can be integrated into [upstart] or whatever
your system's startup process is.

### Deployment/Upgrades with Capistrano et. al.

I don't have any kind of pointers for doing this.  Feedback is welcome
and I'd include it here.  Obviously you'd deploy containers rather than
code, so git and the [Capistrano] deployment model would be very
different, but I'm sure it could be adapted.

The [Spree Commerce] project has a good [deployment setup project] which
includes configurations for bluepill, capistrano and [foreman].  They
don't directly apply here, but if you're looking for inspiration that's
as good a place as any to start.

You could also look at automation through tools like [Chef], [Puppet] or
[Ansible].

### Compiling Assets

The Redmine instructions don't call for precompiling assets and I
haven't done so in this image.  See `dockerfile/README.md` if you want
to compile your assets.

### System Updates

Since the container doesn't run a lot of Ubuntu's normal processes,
the attack surface of a container is pretty much limited to the
application it's running.  However, there may always be updates which
affect some of the software you _are_ running in the container.

Ruby, Rails and gem updates require the image to be rebuilt.

See `dockerfile/README.md` for a discussion of Ubuntu updates.

[Docker]: http://docker.io/
[Redmine]: http://www.redmine.org/
[unicorn]: http://unicorn.bogomips.org/
[Rails]: http://rubyonrails.org/
[git]: http://git-scm.org/
[redmine on github]: https://github.com/redmine/redmine
[Redmine's installation process]: http://www.redmine.org/projects/redmine/wiki/RedmineInstall#PostgreSQL
[docker-pgsql]: https://github.com/binaryphile/docker-pgsql
[docker-redmine]: https://github.com/binaryphile/docker-redmine
[bluepill]: https://github.com/bluepill-rb/bluepill
[Monit]: http://mmonit.com/monit/
[upstart]: http://upstart.ubuntu.com/
[Capistrano]: https://github.com/capistrano/capistrano
[Spree Commerce]: http://spreecommerce.com/
[deployment setup project]: https://github.com/spree/deployment_service_puppet
[foreman]: https://github.com/ddollar/foreman
[Chef]: http://www.opscode.com/chef/
[Puppet]: http://puppetlabs.com/
[Ansible]: http://www.ansibleworks.com/
[dotenv]: https://github.com/bkeepers/dotenv
[hipache]: https://github.com/dotcloud/hipache

