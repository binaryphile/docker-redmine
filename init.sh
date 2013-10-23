#!/bin/sh

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
if [ ! -f "$ROOT_DB_DIR/development.sqlite3" ]; then
  bundle exec rake db:migrate
  bundle exec rake redmine:load_default_data
fi

