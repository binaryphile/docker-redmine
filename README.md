# Redmine Docker Image Control Scripts

These are scripts to control my general-purpose Docker-ized Redmine
image.  The goal is for you to be able to use Redmine without having to
build your own Redmine image.  Hence the things that make a Redmine
instance "yours", i.e. the plugins, file attachments, logs etc., are all
kept outside the image in your local filesystem.

The image is meant to be used as if Redmine had been "compiled" into an
executable (the image).  It's started and controlled from outside the
Docker container, on the host like an executable.  The container stores
no persistent state and there is no visibility inside the container,
just as executables do not store persistent state and do not have
visibility inside them.

## Getting Started with a Demo (development mode)

First copy `sample.env` to `.env`.

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
database is created in this directory under `./redmine/db`.

`demo.sh` runs Redmine in development mode if you want to start it up
again.

## Getting Started with Production

You'll need to have PostgreSQL already running on the local host and the
standard port (5432).  The server should exist but should not have a
redmine user or database yet.

If you haven't already, copy `sample.env` to `.env`.

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

To stop it, run `docker ps -l`, find the id, then run `docker stop
[id]`.

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

ImageMagick is installed.

The container is configured to put logs, Redmine file attachments and
the application's secret_token file on your local filesystem via
mounting the current directory in the container.

Plugins are mounted from the local/plugin folder in this directory.  If
your plugin requires new gems, then the image will have to be rebuilt
with those gems in the Gemfile, unfortunately.  Otherwise you can just
put the plugin in the folder and run its migrations as described below.

The image includes git and mercurial SCM executables.  If you need
others you'll have to rebuild the image.

The image includes all requirements for using PostgreSQL and MySQL in
production.  Development mode only supports sqlite.  If you need MSSQL
in production or anything other than sqlite in development, you'll have
to rebuild the image.

Any modifications to the Redmine source require rebuilding the
image.  The scripts to create images are in the dockerfile folder,
along with their own README.

## Customization

Once you've gotten it working, you may want to do any of the following:

- Customize the Redmine source code
- Customize Redmine with static pages
- Customize Redmine with plugins

### Customize the Redmine Source Code

If you want to work with the Redmine source code, see
dockerfile/README.md.  It describes the development process with Redmine
and Docker, as well as how to build a new Redmine image.

### Customize Redmine with Static Pages

Currently there is no support for putting files in the public folder.
If someone asks me for this, I may work on it.

### Customize Redmine with Plugins

Make sure your database has been initialized with one of the
initialization scripts.

Then simply add your plugins to the plugins folder here.

To run the plugin migrations, run `./migrate.sh`.

Then start up Redmine in either development or production mode with the
appropriate script, `demo.sh` or `redmine.sh` respectively.

It is recommended that you create a git repository in the plugins
directory which stores all of your plugins.  This will make it easier to
deploy in production.

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

Run `daemon.sh` as in Getting Started.

Stop with `docker ps -l` and `docker stop [id]`.

### Deploy an Upgraded Image

If a new version of the image comes out, set the new version in `.env`
for `RM_IMAGE`.

Stop the old container. Then run `./migrate.sh`.

Start the new image with `daemon.sh`.

### Deploy New Plugins

Stop the old container, then pull your changes to the plugins folder.

Run `./migrate.sh` and `daemon.sh`.

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

