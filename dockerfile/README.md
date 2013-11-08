# Docker Redmine Build Scripts

Generates a [Docker] image of [Redmine].

Normally you should only need to build your own image if you need to add
gems to the image, or if you just want to see how the process works.  To
instead run Redmine, you don't need to build an image, you can just pull
and customize my image without the need to rebuild it.

## Usage

- Clone this repo if you haven't already and cd to the `dockerfile`
directory
- 

## Working with the Redmine Code

If you want to deploy a Redmine server, there are a few steps you need
to take to make your code friendly to this Docker image.

The workflow goes like this: first you clone Redmine if you haven't
already.  Then you decide on the branch you want.  I suggest
[latest]-stable.

Clone your repo to your local machine.  Then switch to your chosen
branch.  Here's where you'll be customizing things for the image.

The files in the templates directory in this repo are meant to go into
your branch.  They do a couple things:

- Add/remove git ignores for files that are normally part of deployments
such as `schema.rb`.  Diff with the Redmine version for details.
- Fetch database credentials from environment variables in
`database.yml`.  This allows you to commit the file without compromising
security.
- Add the `dotenv` gem so envrionment variables can be read from a file
in the root of the deployment.
- Add the `mysql2`, `pg` and `sqlite3` gems in `Gemfile.local` so the
container is database-neutral.
- Configure [unicorn] with a `unicorn.rb` file.

Here's the map of where these files go:

- `database.yml`: `/config/database.yml`
- `Gemfile.local`: `/Gemfile.local`
- `sample.gitignore`: `/.gitignore`
- `unicorn.rb`: `/config/unicorn.rb`

Once you have these files in your repo, commit and push.

While you're developing, you'll be doing normal Rails development on
your local machine, not in the container (there are instructions for how
to do development in the container later in this document).

Because `database.yml` constructs the path to the development database
with the ROOT environment variable, you'll need to set that variable to
your project's home.  The easiest way to do that is to create a file
called `.env` in the project's root and set it there using normal shell
syntax such as `export ROOT=/my/project/dir`.  The `dotenv` gem will
pick this up and put it in your environment whenever you run Rails, so
you don't have to source the file.

To run development on your local machine, you'll just follow the typical
Redmine steps.  I won't list those here.  When you're ready to deploy,
just make sure you've got all of the files you need checked in,
including plugins, `Gemfile.lock` and `schema.rb` (which is generated
every time you migrate).

### Creating an Image with your Code

Since your Redmine source is essentially what makes the image what it
is, you'll need to rebuild the image.

If you're using 2.3-stable, the fastest way to rebuild it is to base it
off my 2.3-stable tag, since that already has all of the prereq Ubuntu
packages as well as most of the gems you'll need pre-bundled.  You'll
just need your code added in as well as to `bundle install` again.
You'll only need to `bundle install` since `Gemfile.lock` will already
have the appropriate versions of the gems locked in for you.

You'll end up with a new image that can be deployed to production.
Since your production database will still need to be migrated in some
cases, you'll want to do the migrations in that environment.  We'll get
into that in a moment.  Just know that since the database is outside of
the image, you won't need to run migrations to create the updated image.

Also, if you're not building off my image, you'll need to create your
own, which I'll get to below.

Once your code is pushed to github, you'll want to come back from your
source directory to this project's directory.  Back here, you'll be
running the `create.sh` script to download your code into an image and
run bundler.  The script will handle both steps for you.  You just need
to copy `sample.env` to `.env`, then set RM_BASE, RM_VERSION and GH_USER
appropriately in the new file.  Since you're using my image, RM_BASE is
fine as `binaryphile/redmine:2.3-stable`.  GH_USER should be set to your
github username, and RM_VERSION should be `2.3`.

The copy of your source code which will be copied into your image will
be a raw tar of your latest committed code in that branch, not a git
checkout.  You don't need the added weight of a (large) repo like
Redmine's just to run your code.

The script will also take care of linking a few files to the volume that
will come from your local filesystem, things like the attachments
directory, logs, etc.  In particular, it will link your
`secret_token.rb` file to the outside, since that file is particularly
sensitive (like `database.yml`).  Make sure you aren't checking that
file into git.  If you're using my sample gitignore file, that should be
taken care of for you already.

Finally, the script will run `bundle install --without test`.  I'm
debating whether to turn on the production flag, but for now it's just
without test.  This means you'll be able to run Redmine in either
production or development mode.

So go ahead and run `./create.sh` once you have `.env` sorted out.  It
should be very fast and you'll just see the code being unpacked and
bundler running.

When it's done, you'll have an exited container in your `docker ps`
output.  It's up to you to commit this container as an image and
optionally push to the index.  If you've followed my directions and
there is no confidential information in your code, you can safely push
to the public index since the image will have no confidential or
stateful information inside.

Run `docker ps` to determine the id of the container, then `docker
commit [id] [your index id]/redmine`.  I don't suggest tagging it, since
your latest should always be the latest customized version of yours.
Only tag images that should be reusable to someone else or in some other
way (such as a build with prereqs installed).

Finally, `docker push [your index id]/redmine` if you want to make the
image available.

### Deploying your Image for the First Time

If you're deploying for the first time without a preexisting database,
you'll need to set one up in your production environment.  The image
will connect to PostgreSQL running on the default port **on the Docker
host**.

That's an entirely separate exercise, although I can point you to my
PostgreSQL image at <https://github.com/binaryphile/docker-pgsql>.
You'll need your database server to have a running database with a
superuser, but you don't have to create the redmine database or user, my
scripts will do that.  You'll only need to configure the redmine and
superuser credentials into `.env`.

You can run with a MySQL database by changing the database adapter in
the `.env` file on your production machine.  I haven't tried this and
don't have any further help for you there.

The first thing to do is to clone this repository to your production
machine, the Docker host.  Then copy `sample.env` to `.env`.  `.env`
already appears in the git ignores, so you won't check in any sensitive
information accidentally.

Edit `.env` and add your image's name as RM_IMAGE, your database
superuser credentials as SU_NAME and SU_PASS and your desired redmine
user as DB_USER and DB_PASS.  The rest of the variables can stay
default.

Presuming your PostgreSQL database is running on the docker host on the
default port, you're ready to initialize the database and the host
environment.  This involves creating the redmine user and database,
creating the expected files on the local filesystem, initializing your
secret token and populating the database with the schema and default
Redmine data.

Run `./initialize-production.sh`.  It will take care of everything,
including downloading your image.  Note that it will run the container a
few times as it does different steps, so you'll see Dockers DNS warnings
more than once.  These can be ignored.

Once it's done, you can verify that it's working by running
`./daemon.sh`, which will start unicorn on port 3001 on the host.  Point
your browser at the production server, such as
http://[yourserver.com]:3001/.

If it works, you're golden.  If not, see if the container is running
with `docker ps`.  If so, stop it with `docker stop [id]`.  You can try
debugging with `./interactive.sh`, which will open a prompt inside the
container.  You will need to set RAILS_ENV to production once you're
inside the container since `interactive.sh` defaults to development
mode.

### Stopping and Starting the Container

Since all of the state is kept outside the container, you should start
it with `daemon.sh`, which spawns a new container from the image every
time by using the docker run command.

You should not need to use the docker start command to restart a
container.

To stop a container, look up its id with `docker ps` and stop it with
`docker stop [id]`.

Old containers are disposable and can be removed with `docker rm [id]`.
If no containers are currently running, you can remove them all with the
command `docker rm $(docker ps -a -q)`.

### Deploying an Upgraded Image

When you need to deploy another version of your code, you'll follow the
same process as you did to build it in the first place.  On your local
machine, you'll commit and push your code to github, run `./create.sh`,
using `binaryphile/redmine:2.3-stable` as RM_BASE.  Then you'll commit
as latest (no tag) and push to the index.

Once have the image ready, go to the deployment machine and the
directory for this repo.  This time, you only need to stop the old
container, pull the new one and optionally run migrations.

Use `docker ps` and `docker stop [id]` to stop the old container.  Then
run `docker pull [your index id]/redmine`.  That should pull your latest
version.

If you have new migrations to run (say, you've added a plugin that
requires them), then you'll run `./migrate.sh`.

If you don't have any migrations to run, or once you've run them, then
you can simply start the new version with `./daemon.sh`.

That should cover all of your typical usage of the images.

## Other Deployment Considerations

### A Note on Unicorn

Unicorn is used for production because it easily allows multiple worker
processes to run behind a single application server port.

You can use the `.env` variable U_WORKERS to set the number of worker
processes.  Usually you'll want it set to the number of CPUs on the host
machine.  If not set explicitly it will default to 2 in my setup.  Even
if you have one processor, I suggest you have at least 2 worker
processes.

A unicorn feature which containers render useless is the hot-upgrade
behavior.  Since unicorn is inside the container, when you upgrade the
container you have to stop unicorn completely.  There isn't a comparable
feature in my setup here, but you can certainly investigate [hipache],
which is the Docker company's project for orchestrating container
upgrades, among other features.

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

## Recreating the Images for Other Redmine Versions

If you are building another version of Redmine, or if you need other
underlying prerequisites (ubuntu, ruby, imagemagick, etc.),  you can
rebuild the underlying images using these scripts.

I built them as a stack of four layers:

- ubuntu:precise - the stock image from Docker, Inc.
- binaryphile/ruby:2.0.0-p247 - a ruby 2.0 install from source
- binaryphile/redmine:2.3-prereqs - all of the prerequisite Ubuntu
packages including SCM and database adapters
- binaryphile/redmine:2.3-stable - a stock Redmine 2.3-stable clone with
just the adaptations to make it work in an image

I recommend using the same stacking approach, as each layer greatly
speeds working on the next.  I won't go into much depth, but you can
remake them yourself with these directions:

### Base Box

Just choose one of the other boxes from Docker.

### Ruby

Find directions for building a Ruby image based on mine:
<https://github.com/binaryphile/docker-ruby>.

### Redmine Prereqs

This repo has a prereqs subdirectory.  By changing to that directory and
adapting that directory's `sample.env` to `.env`, you can follow the
same procedure for creating a prereq image.  Commit and push the
appropriate tag for your situation.

### Redmine Bundled

To create a tagged, bundled Redmine, it's exactly the same procedure as
creating your own updated one.  If you plan on making the tag publicly
available, though, I would urge you to consider not including any
customizations in your tag, unless including your customizations is the
purpose of your image in the first place.

## Tinkering with the Scripts

I wrote this all in shell since most of the process consists of issuing
CLI commands.  Almost everything in them can be overridden with
environment variables if you examine what the scripts are doing.

I've tried to make it so that setting a variable once in `.env` will
alter all of the scripts where appropriate.  If you aren't using `.env`,
you can just set them in your environment directly and the scripts will
still work, which is why there are a lot of values coded into the
scripts that you wouldn't normally concern yourself with.

There are some scripts which are meant to be used in certain contexts,
usually the RAILS_ENV and the options passed to `docker run`.  These
scripts have those variables coded into them and may behave funny if you
override RAILS_ENV etc. in `.env`.  Be careful.

If you are using `.env`, I don't think you can override those variables
by setting the same ones in your environment directly.

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

