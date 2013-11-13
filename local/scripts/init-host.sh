#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${ROOT=/root/local}
: ${ROOT_FILES_DIR=$ROOT/files}
: ${ROOT_LOG_DIR=$ROOT/log}
: ${ROOT_DB_DIR=$ROOT/db}
: ${RM_DIR=/redmine}
: ${ROOT_SECRET_DIR=$ROOT/config/initializers}

mkdir -p $ROOT_FILES_DIR
mkdir -p $ROOT_LOG_DIR
mkdir -p $ROOT_DB_DIR
mkdir -p $ROOT_SECRET_DIR
cd $RM_DIR
if [ -e "$ROOT/Gemfile.lock" ]; then
  rm Gemfile.lock $ROOT
else
  mv Gemfile.lock
fi
ln -s $ROOT/Gemfile.lock Gemfile.lock
bundle install --path $ROOT/.bundle
if [ ! -e "$ROOT_SECRET_DIR/secret_token.rb" ]; then
  bundle exec rake generate_secret_token
fi

