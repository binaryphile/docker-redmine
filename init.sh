#!/bin/bash

: ${ROOT=/root}
: ${ROOT_FILES_DIR=$ROOT/files}
: ${ROOT_LOG_DIR=$ROOT/log}
: ${ROOT_DB_DIR=$ROOT/db}
: ${RM_DIR=/redmine}
: ${ROOT_SECRET_DIR=$ROOT/config/initializers}
export REDMINE_LANG=en

mkdir -p $ROOT_FILES_DIR
mkdir -p $ROOT_LOG_DIR
mkdir -p $ROOT_DB_DIR
mkdir -p $ROOT_SECRET_DIR
cd $RM_DIR
if [ ! -f "$ROOT_SECRET_DIR/secret_token.rb" ]; then
  bundle exec rake generate_secret_token
fi
if [ ! -v RAILS_ENV ] || [ "$RAILS_ENV" == "development" ] && [ -f "$ROOT_DB_DIR/development.sqlite3" ]; then
  rm $ROOT_DB_DIR/development.sqlite3
fi
if [ "$RAILS_ENV" == "production" ]; then
  export PGPASSWORD=$SU_PASS
  export PGUSER=$SU_USER
  export PGHOST=$DB_HOST
  psql template1 <<< "CREATE ROLE $DB_USER LOGIN ENCRYPTED PASSWORD '$DB_PASS' NOINHERIT VALID UNTIL 'infinity';"
  psql template1 <<< "CREATE DATABASE $DB_USER WITH ENCODING='UTF8' OWNER=$DB_USER;"
fi
bundle exec rake db:migrate
bundle exec rake redmine:load_default_data

