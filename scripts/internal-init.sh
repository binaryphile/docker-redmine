#!/bin/bash

if [[ -e .env ]]; then
  source .env
fi

: ${ROOT=/root}
: ${RM_BRANCH=$RM_VERSION-stable}
: ${RM_DIR=$ROOT/$RM_BRANCH}
: ${BDL_DIR=/redmine/.bundle}
: ${SECRET_FILE=$RM_DIR/config/initializers/secret_token.rb}
: ${PID_DIR=$RM_DIR/pids}
: ${LANG=en}
export REDMINE_LANG=$LANG

cd $RM_DIR
if [[ ! -d .bundle ]]; then
  cp -R $BDL_DIR .
fi

if [[ ! -e "$SECRET_FILE" ]]; then
  bundle exec rake generate_secret_token
fi

mkdir -p $PID_DIR

if [[ -v RAILS_ENV && "$RAILS_ENV" == production ]]; then
  export PGPASSWORD=$SU_PASS
  export PGUSER=$SU_USER
  export PGHOST=$DB_HOST
  psql template1 <<< "CREATE ROLE $DB_USER LOGIN ENCRYPTED PASSWORD '$DB_PASS' NOINHERIT VALID UNTIL 'infinity';"
  psql template1 <<< "CREATE DATABASE $DB_USER WITH ENCODING='UTF8' OWNER=$DB_USER;"
  touch ../.production
fi

bundle exec rake db:migrate
bundle exec rake redmine:load_default_data

