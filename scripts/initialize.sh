#!/bin/bash -ex

if [[ ! -e .env ]]; then
  cp sample.env .env
fi

source .env

if [[ ! -v ROOT ]]; then ROOT=/root; fi
if [[ ! -v RM_BRANCH ]]; then RM_BRANCH=$RM_VERSION-stable; fi
if [[ ! -v RM_DIR ]]; then RM_DIR=$ROOT/current; fi
BDL_DIR=/redmine/.bundle
SECRET_FILE=$RM_DIR/config/initializers/secret_token.rb
PID_DIR=$RM_DIR/pids
if [[ ! -v REDMINE_LANG ]]; then export REDMINE_LANG=en; fi

cd $RM_DIR
if [[ ! -d .bundle ]]; then
  cp -R $BDL_DIR .
fi

if [[ ! -e "$SECRET_FILE" ]]; then
  bundle exec rake generate_secret_token
fi

mkdir -p $PID_DIR

if [[ "$RAILS_ENV" == production ]]; then
  : ${DB_USER?"need to set database username DB_USER, see README.md"}
  : ${DB_PASS?"need to set database password DB_PASS, see README.md"}
  : ${SU_USER?"need to set database superuser name SU_USER, see README.md"}
  : ${SU_PASS?"need to set database superuser password SU_PASS, see README.md"}
  if [[ ! -v DB_HOST ]]; then DB_HOST=172.17.42.1; fi
  export PGPASSWORD=$SU_PASS
  export PGUSER=$SU_USER
  export PGHOST=$DB_HOST
  psql template1 <<< "CREATE ROLE $DB_USER LOGIN ENCRYPTED PASSWORD '$DB_PASS' NOINHERIT VALID UNTIL 'infinity';"
  psql template1 <<< "CREATE DATABASE $DB_USER WITH ENCODING='UTF8' OWNER=$DB_USER;"
  touch $ROOT/.production
fi

cd $RM_DIR
bundle exec rake db:migrate
bundle exec rake redmine:load_default_data

