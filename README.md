# Single-serving Redmine Docker image

## Description

Generates a [Docker] image for [Redmine].

Before you go building Redmine 2.3-stable, you can use my image by
running:

    docker pull binaryphile/redmine:2.3-stable

That image contains a vanilla (no plugins) Redmine 2.3-stable (latest at
time of writing).  It also includes [unicorn] for production use, but
you won't need that if you're just taking it out for a spin.  You can
easily run in development mode, but production mode requires passing in
db configuration and credentials through environment variables.  See
below for usage.

Ruby 2.0.0-p247 and all dependencies are included in the container, so
running it doesn't require any bundling or software installation.

The container is configured to put logs and files uploaded to Redmine on
your local filesystem via mounting the current directory in the
container.

Any modifications to Redmine require rebuilding the container, which
the scripts given here help simplify.

## Basic Usage (Development Mode)

If you just want to take Redmine out for a test drive, it's simple to
run this container in Rails' development mode:

    ./run.sh # run on the host, your machine
    # cd root # now in the container
    # ./init.sh
    # cd /redmine
    # bundle exec rails s

Then, on your local host, point your web browser at
<http://localhost:3000/>.  Admin login is `admin`, password `admin`.

## Production/Custom Usage

### Development

Running a [Rails] app in a Docker container is a bit more involved than
a regular package, so these instructions are bound to be a little more
convoluted than most.  Usually you want the ability to modify and extend
Rails apps with plugins, for example.  This means that the source of the
app is changing, and Docker tends to freeze your app in place.

Rather than try to keep the source code for the app outside the
container, the container is set up so you maintain your source in a
version control system ([git]) and rebuild your container when you want
to update the app for production.  Usually you would do development
locally without using the container, but you can certainly mount your
dev code so it runs in the exact same environment as production.
Scripts are included to ease rebuilding the container.

The general workflow looks like this:

- Fork redmine on [github] and clone it to your local machine
- Edit the following files to reference your github/docker account and
the redmine version:
  - `install.sh`
  - `prep.sh`
  - `run.sh`
- Checkout the branch you want, usually [version]-stable
- Import the files from my repo:
  - `.gitignore` - allows you to check in important files that Redmine
  ignores by default, plus ignore a couple that you'll generate
  - `database.yml` - allows the db to be specified through ENV variables
  - `Gemfile.local` - adds custom gems to the project while avoiding
possible future merge conflicts in `Gemfile` (you may instead want to
    include your gems in `Gemfile` so you see conflicts when they arise)
  - `unicorn.rb` - configures unicorn for production, 2 workers by
  default
- Do your development as you would usually, running dev on your local
machine
- When your code is ready to deploy, commit and push your branch to
github

### Building the Image

- Change to this repo's directory
- Run `prep.sh` to grab a tar of your latest code
- Start install your code in a new Ruby-only container:
    docker run -i -t -v $(pwd):/root -e HOME=/root binaryphile/ruby:2.0.0-p247 /bin/bash
    # cd /root
    # ./install.sh
    # exit
  This will install your code in the machine, handle directory
  permissions and link key directories to the local filesystem.
- Commit the new image:
    docker ps -a # find the container id that you just ran
    docker commit [id] [your name]/[repo]
  I don't recommend tagging custom versions of development since you'll
  always want to pull latest.
- Remove the old container if you want:
    docker rm [id]
- Push your image if you want:
    docker push [your name]/[repo]

That's it for creating the image.  Now you can pull that image
anywhere you want.

If you're just running development mode, follow the basic usage
instructions above to run the machine.

### Supplying the Database

To run production for the first time, you'll need to make some decisions
about deployment.  This image should work with both MySQL and
PostgreSQL.  I haven't tested MySQL though.

To run with PostgreSQL, you'll need an instance.  You can find
instructions for mine at <https://github.com/binaryphile/docker-pgsql>.

Once you've gotten that initialized, you'll need to run through the
[Redmine installation docs] related to initializing the database.  I
recommend exposing the 5432 port on the host so you can just use the
`psql` client directly from the host or elsewhere.  Observe your
organization's security practices as necessary.  I don't go into the
details of using Docker's private networking since it's much more
involved, despite it being more secure.

### Running the containers

You'll probably want to run the database and Redmine containers on the
same host as each other.  Test it out first on your own machine, but if
you're looking to put them into production, you'll want to clone or copy
both the [docker-pgsql] and [docker-redmine] repos to your production
machine so these scripts are available.  Running them either on your
local machine or the production host takes the same process described
here.

First run the PostgreSQL container so it's available and exposed on port
5432.

For Redmine to know about the database, you'll need to pass in the
environment variables defined in `database.yml`:

- `DB_ADAPTER` - the adapter for your database system, should be
`postgresql`
- `DB_DATABASE` - the database name, usually `redmine`
- `DB_HOST` - `localhost` in this case
- `DB_USERNAME` - the user you configured, usually `redmine`
- `DB_PASSWORD` - your password

You pass these into the container by setting environment variables
throuth the docker command line with the `-e` option.  Here's an
example for an interactive command-line session:

    docker run -i -t -v $(pwd):/root -p :3001 -e RAILS_ENV=production -e DB_ADAPTER=postgresql -e DB_DATABASE=redmine -e DB_HOST=localhost -e DB_USERNAME=redmine -e DB_PASSWORD=mypassword [your repo]/redmine /bin/bash

For these to take effect, you _must_ run Redmine in production mode.
Development is hardcoded to use sqlite in the home directory of the
container.

This command also exposes port 3001 on the host, so be aware of that.

You'll probably want to edit `run.sh` or another script to code these
in, so you don't have to type all that in all of the time.

Next run Redmine in order to initialize the database with its default
seed data.  In this repo's directory:

    ./run.sh # Your edited version
    # cd /root
    # ./init.sh
    # exit

This is the moment of truth.  If the migrations run, you're golden.

If not, you'll have to do some debugging, which is beyond my scope here.
Good luck.

Now discard the container (get used to doing this step):

    docker ps -a
    docker rm [id]

Now that the database is tested and initialized, you're ready to run the
server in production mode with unicorn.  Edit or add a script with the
following:

    docker run -d -v $(pwd):/root -w /redmine -p :3001 -e RAILS_ENV=production -e DB_ADAPTER=postgresql -e DB_DATABASE=redmine -e DB_HOST=localhost -e DB_USERNAME=redmine -e DB_PASSWORD=mypassword [your repo]/redmine bundle exec unicorn_rails -c config/unicorn.rb -p 3001 -D

Verify that the container is running and test by pointing a browser at
port 3001.

Congrats, you have it running in production.

### Running a Proxy Server

Unicorn is certainly capable of running on port 80, and you can use it
directly by changing all of the instances of port 3001 on the command
line above.

However, if you want to run other websites from the same host or to run
with SSL, you'll want a proxy server such as Apache, nginx or even IIS
to front unicorn.  I don't have such a container made for you, nor do I
have the instructions on how to do so since that's a whole other ball of
wax.

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
includes configurations for bluepill, capistrano and [foreman].

You could also certainly look at automation through tools like [Chef],
[Puppet] or [Ansible].

### Precompiling Assets

The Redmine instructions don't call for precompiling assets, and to play
it safe since I haven't had time to test it, I haven't done so in my
image.  You can build the image with precompiled assets by adding this
line after `bundle install` in `install.sh`:

    bundle exec rake assets:precompile

[Docker]: http://docker.io/
[Redmine]: http://www.redmine.org/
[unicorn]: http://unicorn.bogomips.org/
[Rails]: http://rubyonrails.org/
[git]: http://git-scm.org/
[github]: https://github.com/redmine/redmine
[Redmine installation docs]: http://www.redmine.org/projects/redmine/wiki/RedmineInstall#PostgreSQL
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

