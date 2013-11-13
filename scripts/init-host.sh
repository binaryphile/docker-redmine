#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${ROOT=/root}
: ${RM_DIR=/redmine}
: ${SECRET_DIR=$ROOT/config/initializers}
: ${PID_DIR=$ROOT/pids}

cd $ROOT
if [ ! -d "$ROOT/.bundle" ]; then
  cp -R $RM_DIR/.bundle .
fi
if [ ! -e "$SECRET_DIR/secret_token.rb" ]; then
  bundle exec rake generate_secret_token
fi
mkdir -p $PID_DIR

