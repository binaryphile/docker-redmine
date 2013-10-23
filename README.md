# Reusable Redmine Docker image

## Description

Generates a [Docker] image of [Redmine].

Before you go building Redmine 2.3-stable, you can use my image by
running:

    docker pull binaryphile/redmine:2.3-stable

Don't pull without the "2.3-stable" tag since that will be my personal,
customized redmine for my company's deployment, which is not what you
want.

To run a demo of Redmine in development mode, run:

    export RM_IMAGE=binaryphile/redmine:2.3-stable
    ./demo.sh

Then point your browser to http://localhost:3000/.  Admin user is
"admin", password "admin".  You'll want to change this if the system is
on an untrusted network.  Port 3000 will be available to the general
local network unless you configure some sort of firewall.

To run a production server, follow the directions below for setting up a
database server.  Then run:

    export RM_IMAGE=binaryphile/redmine:2.3-stable
    export DB_USER=[your db username]
    export DB_PASS=[your db password]
    ./initialize-production.sh
    ./daemon.sh

Then point your browser to http://localhost:3001/.

You may also need to export settings for DB_ADAPTER and DB_DATABASE
depending on how your database is set up.

## Contents

That image contains a vanilla (no plugins) Redmine 2.3-stable (latest at
time of writing).  It also includes [unicorn] for production use, but
you won't need that if you're just taking it out for a spin.  You can
easily run in development mode.  If you plan on running in production,
you will need to pass in db configuration and credentials through
environment variables.  See below for usage.

Ruby 2.0.0-p247 and all dependencies are included in the container, so
running it doesn't require any bundling or software installation.

The container is configured to put logs, Redmine file attachments and
the application's secret_token file  on your local filesystem via
mounting the current directory in the container.

Any modifications to Redmine, including adding plugins, require
rebuilding the container, which the scripts given here help simplify.

## Usage

### Development with Redmine (not development mode)

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

- In this repo, edit the following files to reference your github/docker
account and the redmine version:
- Fork redmine on [github] and clone it to your local machine
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
- Install your code in a new Ruby-only container:

```
docker run -i -t -v $(pwd):/root -e HOME=/root binaryphile/ruby:2.0.0-p247 /bin/bash
# cd /root
# ./install.sh
# exit
```

This will install your code in the container, handle directory
permissions and link key directories to the local filesystem.

- Commit the new image:

```
docker ps -a # find the container id that you just ran
docker commit [id] [your name]/[repo]
```

 I don't recommend tagging custom versions of development since you'll
 always want to pull latest.

- Remove the old container if you want:

```
docker rm [id]
```

- Push your image if you want:

```
docker push [your name]/[repo]
```

That's it for creating the image.  Now you can pull that image
anywhere you want.

If you're just running development mode, follow the basic usage
instructions above to run the container.

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
through the docker command line with the `-e` option.  Here's an
example for an interactive command-line session:

    docker run -i -t -v $(pwd):/root -p :3001 -e RAILS_ENV=production -e DB_ADAPTER=postgresql -e DB_DATABASE=redmine -e DB_HOST=localhost -e DB_USERNAME=redmine -e DB_PASSWORD=mypassword [your repo]/redmine /bin/bash

For these to take effect, you _must_ run Redmine in production mode.
Development is hardcoded to use sqlite in the `/root` directory of the
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

## Running Development Code with the Container

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

The `run.sh` script should set you up just fine if you are only running
in development mode, otherwise you'll need to use the same script you
created to run production.

Once your container is started and the code is in `/root`, just change
to that directory and run `init.sh` (assuming you need to create the
sqlite db) and then `bundle exec rails s`.  You can use your browser on
your host to go to <http://localhost:3000/>.  You can also edit the
files from the host and the changes will be seen in the container
automatically and immediately.

Don't forget to discard the container when you're done and go through a
github commit/push, then build a new image as above.  Since I expect to
go through many cycles of this process as I deploy, I don't tag these
images and instead always use latest, which is the default if you don't
specify a tag.

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
stale pretty much immediately.

Updating images other than that method just makes them fatter while
still needing to be updated again when you deploy them.  That's why I'm
not a fan of trying to update them before deployment.

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

