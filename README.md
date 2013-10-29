# Reusable Redmine Docker image

Generates a [Docker] image of [Redmine].

## Before you build

You can already use the Redmine image I've created with these scripts by
cloning this repo and running:

    docker pull binaryphile/redmine:2.3-stable

Don't pull without the "2.3-stable" tag since that will be my personal,
customized redmine for my company's deployment, which is not what you
want.

To run a demo of Redmine in development mode, run:

    export RM_IMAGE=binaryphile/redmine:2.3-stable
    ./initialize-development.sh
    ./demo.sh

Then point your browser to http://localhost:3000/.  Admin user is
"admin", password "admin".  You'll want to change this if the system is
on an untrusted network.  Port 3000 will be available to the general
local network unless you firewall it.

To run a production server, follow the directions below for setting up a
PostgreSQL database server.  Then run:

    export RM_IMAGE=binaryphile/redmine:2.3-stable
    export DB_USER=[your db username]
    export DB_PASS=[your db password]
    ./initialize-production.sh
    ./daemon.sh

Then point your browser to <http://localhost:3001/>.

You may also need to export settings for DB_ADAPTER if you want to use
MySQL rather than PostgreSQL.

You may also set your environment variables by copying `sample.env` to
`.env` and editing with your values.  `.env` is automatically called by
the other scripts if it exists.

## Contents

That image contains a vanilla (no plugins) Redmine 2.3-stable, the
latest at the time of this writing.  It also includes [unicorn] for
production use, but you won't need that if you're just taking it out for
a spin.  You can easily run in development mode.  If you plan on running
in production, you will need to pass in db configuration and credentials
through environment variables or the `.env` file.  See below for usage.

Ruby 2.0.0-p247 and all dependencies are included in the container, so
running it doesn't require any bundling or software installation.

The container is configured to put logs, Redmine file attachments and
the application's secret_token file on your local filesystem via
mounting the current directory in the container.

Any modifications to Redmine, including plugins, require rebuilding the
container which the scripts given here help simplify.

## Usage

### Development with Redmine (as in coding not just development mode)

Running a [Rails] app in a Docker container is a bit more involved than
a regular package.  Usually you want the ability to modify and extend
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

- Export the variables (you can also set them in your .env file)
- Fork [redmine on github] and clone it to your local machine
- Checkout the branch you want, usually [version]-stable
- Copy the files from my repo into the redmine repo:
  - `_.gitignore` - copy to `.gitignore`
    - allows you to check in important files that Redmine ignores by
    default, plus ignore a couple that you'll generate
  - `database.yml` - allows the db to be specified through ENV variables
    - production:
      - DB_ADAPTER - the adapter as would be specified in `database.yml`
      - DB_DATABASE - the name of the database, e.g. "redmine"
      - DB_USER - the regular database user, not the superuser
      - DB_PASS - the regular database user's password
    - development:
      - ROOT - should be set to the location that is mounted in the
      container from your local filesystem
  - `Gemfile.local` - adds custom gems to the project
    - to avoid merge conflicts with future changes in `Gemfile`, you can
    use this
    - if you want to see any potential conflicts, use `Gemfile` directly
    include your gems in `Gemfile` so you see conflicts when they arise)
  - `unicorn.rb` - configures unicorn for production
    - 2 workers by default, settable with the U_WORKERS variable
  - `sample.env` - copy to `.env` and set the variables there so you
  don't have to set them in every new shell instance
- Do your development as you would usually, running dev on your local
machine
- When your code is ready to be built into an image, commit and push
your branch to github
  - the `create-image.sh` script will automatically download the latest
  commit in your branch

### Building the Image

- Change to this repo's directory
- Set RM_BASE to your base ruby image (e.g.
    `binaryphile/ruby:2.0.0-p247` using `export` or in `.env`.
- Create the image:

```
./create-image.sh
```

This will install your code in the container, handle directory
permissions and link key directories to the local filesystem.

- Commit the new image:

```
docker ps -a # find the container id that you just ran
docker commit [id] [your name]/[repo]
```

  I don't recommend tagging.  For custom versions of your development
  you'll always want to pull the default latest, which doesn't carry a
  tag.

- (optional) Remove the old container:

```
docker rm [id]
```

- (optional) Push your image:

```
docker push [your name]/[repo]
```

That's it for creating the image.  Now you can pull that image anywhere
you want.

If you're just running development mode, follow the basic usage
instructions above to run the container.

### Things to Know About the Image

The idea here is to provide you with a truly reusable container.  Yes,
it's only reusable insofar that you want to run the exact same code more
than once, but that means two important things:

- The image can be shared publicly, even if intended for use in
production, so long as there is no confidential information in the code.
- The image can be replaced or upgraded without having to export your
state data and config.

Assuming you don't have any confidential code in your app, you can share
the image publicly because we've taken all of the configuration and
state data, including credentials, out of the container.  Most notably,
that means:

- `config/database.yml` receives database credentials from the
environment (using the `dotenv` gem, see below)
- `config/initializers/secret_token.rb` is symlinked to a file of the
same name outside the container
- the file attachments directory for Redmine is symlinked to a folder
outside the container
- the log directory is symlinked to a folder outside the container
- the development database (sqlite3) is written outside the container
- the environment variable file `.env` is symlinked to a file outside
the container

All of these files/directories will be in the directory of this repo, or
wherever you decide to run the scripts from.

[dotenv] is also included in the image by default.  It's a simple gem
that allows Rails apps to get their environment read from a file named
`.env` in the root of the project.  You don't have to use the `.env`
file, but it is recommended since reportedly some systems can expose the
environment variables fed to a process.  dotenv instead loads the
variables directly from the file once the app has started, which should
protect them from prying eyes.  Make sure your security on the file is
adequate.

The image also comes with Mercurial and Git installed by default for use
with Redmine's source control features.

Redmine will be configured to run as root in the image.

The necessary file permissions for the directories mentioned in
Redmine's installation docs will also be taken care of.

### Supplying the Database

To run production for the first time, you'll need to make some decisions
about deployment.  This image should work with both MySQL and
PostgreSQL.  I haven't tested MySQL.

To run with PostgreSQL, you'll need an instance.  You can find
instructions for mine at <https://github.com/binaryphile/docker-pgsql>.

Once you've gotten the PostgreSQL database initialized using the
instructions from my other repo, run it as a daemon on port 5432.  Note
that it will be exposed to the network on the host.

In this repo, run:

    ./initialize-production.sh

This will run [Redmine's installation process] which will create a
Redmine user and database and will also run the migrations and install
the default data.

### Running the containers

You'll probably want to run the database and Redmine containers on the
same host as each other.  Test it out first on your own machine, but if
you're looking to put them into production, you'll want to clone or copy
both the [docker-pgsql] and [docker-redmine] repos to your production
machine so these scripts are available.  Running them either on your
local machine or the production host takes the same process described
here.

First run the PostgreSQL container so it's available and exposed on port
5432, if it's not already running.

For Redmine to know about the database, you'll need to pass in the
environment needed by `database.yml`:

- `DB_ADAPTER` - the adapter for your database system, should be
`postgresql`
- `DB_DATABASE` - the database name, usually `redmine`
- `DB_HOST` - `localhost` in this case
- `DB_USERNAME` - the user you configured, usually `redmine`
- `DB_PASSWORD` - your password



    ./daemon.sh

This command exposes port 3001 on the host, so be aware of that.

This is the moment of truth, you should now be able to do a `docker ps`
and see both containers running.

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
includes configurations for bluepill, capistrano and [foreman].  They
don't directly apply here, but if you're looking for inspiration that's
as good a place as any to start.

You could also look at automation through tools like [Chef], [Puppet] or
[Ansible].

### Precompiling Assets

The Redmine instructions don't call for precompiling assets, and to play
it safe since I haven't had time to test it, I haven't done so in my
image.  You can build the image with precompiled assets by adding this
line after `bundle install` in `install.sh`:

    bundle exec rake assets:precompile

## Running Development Code with the Image

Sometimes you'll need to debug production issues with development code,
or perhaps you just like to run your development in the exact same
environment as production so there are no surprises upon deployment.
You can also do testing in a staging environment locally on your
development machine by using the production container.  There are lots
of uses.

If you need a true copy of the database along with the PostgreSQL
server, you'll need to copy those from production or a backup and
recreate the setup as described above.  Fortunately this shouldn't be
too hard, that's the entire point and payoff of containerization.

Otherwise you can run in development mode and it should fairly closely
recreate production, only using sqlite and a test database.

The key is to run the container from the same directory as your
development code, which will make it visible to the container in
`/root`.  Just ignore the fact that there's a production copy in
`/redmine`.

I do this by copying (symlinking isn't sufficient) the scripts from this
repo into the redmine source directory, along with .env.

Make sure you have the variables for RM_IMAGE, etc set up, then run:

    ./initialize-development.sh
    ./interactive.sh

This will start up a command line in the container, set to development
mode.  Then:

    # cd /root
    # bundle install
    # bundle exec rails s

## A Note About Users and Security

Docker is new and so there isn't a lot of experience with it out there
to draw on, so don't take my word as gospel, or even rely on it at all.
I'm concerned about security and the jury is still out on that.

There are three things I'll mention, one is container security in general,
another is the choice of user which Redmine runs under and, finally, is
the status of Ubuntu updates in the container.

### Container Security

The Docker folks give some assurances about how secure containers are,
but they are realistic in that they know new technologies need to
establish a track record before they can be truly vetted.  Caveat
emptor, buyer beware.  That said, Docker is based on LXC containers, so
that's where most of the implications lie.  There are many more folks
starting to adopt LXC and/or Docker, including Red Hat, so there's at
least some promise in that regard.  Still, the docker daemon runs as
root, so should there be issues, the host may be at risk.

That said, the containers themselves serve as a partition which makes
a separation of concerns/responsibilities.  Compromising an application
in a container no longer necessarily means getting the run of the host
machine.  So there's some reason to think containers may be a more
secure method of deployment than running multiple applications in the
same host environment.

One thing I'll note is that whenever you run a container in my model,

you're always starting from a "frozen" image.  The old running
container, if there was one, is discarded.  That means if a container
has been compromised, the attacker's exploit would be lost whenever a
new container is run and they would have to compromise your container
once more.  If you're updating your image with the latest security
patches, you may actually be able to eject an attacker from what was
once a compromised system.  It's analogous to taking an image backup of
a clean system's OS drive and going back to that known-good image
when a system gets compromised somehow.  It's a good security mechanism.

That presumes the attacker hasn't compromised the container somehow in
the first place, of course.

### Running as Root

That leads me to the second point, running as root.  While the
PostgreSQL image doesn't run as root, the Redmine instance does.
Remember that this is root only within the container.  This is analogous
to setting up an application account on the host, which normally would
have full run over anything in the app.  The container performs that
same isolation for us, so we shouldn't necessarily pay attention to the
automatic allergic response we've been trained to have about running
things as root.

You can go a lot more in-depth on security, so I'll suggest you google
around and/or participate in the mailing list or irc channel for docker.

One good reason to run as root, besides making container configuration
easier, is that the volume mounting capability of Docker (LXCs?) does no
user mapping, so created files on the host have the container user's
uid.  If you use any old uid in the container, they probably won't have
write permissions to the local directory and writes will fail.  Running
as root in the container results in files written by root on the local
filesystem, which while less than optimal is better than failure.

### System Updates

Since the container doesn't run a lot of Ubuntu's normal processes,
there's less to worry about.  However, there may always be updates which
affect some of the software you _are_ running in the container.

Ruby and gem updates naturally require you to rebuild the image.

Ubuntu updates should likely be done periodically as well.  I haven't
included them in this process since I believe you want to do it outside
the image, when you run a container for the first time.  I suggest as
part of your initializing the container, you take an additional step of
running it interactively once to perform system updates, then committing
that as a new local image and running from it (this is another reason to
not run from explicit tags).  You probably _don't_ want to push those
images to the index, however, as there will be lots of them and they go
stale pretty much immediately.  I would commit to an unrelated repo name
just to be safe so I don't push to the index by accident.

If you keep updating images and committing them to your main repo, you
just make them fatter without preventing the need to upgrade on deploy
anyway.  That's why I'm not a fan of trying to update them before
deployment.

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

