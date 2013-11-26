#!/bin/bash

if [ -e ".env" ]; then
  source .env
fi

: ${RM_IMAGE?"need to set redmine image RM_IMAGE, see README.md"}
: ${RM_VERSION?"need to set redmine version RM_VERSION, see README.md"}

: ${ROOT=/root}
: ${RM_BRANCH=$RM_VERSION-stable}
: ${RM_DIR=$RM_BRANCH}
: ${MT_DIR=$(pwd)}
: ${WK_DIR=$ROOT/$RM_DIR}
: ${RM_USER=redmine}

if [ -v RAILS_ENV -a "$RAILS_ENV" == "production" ]; then
  : ${U_WORKERS=2}
  : ${RM_PORT=3001}
  : ${U_ROOT=$WK_DIR}
  : ${MODE=-d}
  : ${RE="-e RAILS_ENV=$RAILS_ENV"}
  : ${CMD="bundle exec unicorn_rails -c config/unicorn.rb"}
else
  : ${RM_PORT=3000}
  : ${MODE="-i -t"}
  : ${CMD="bundle exec rails s"}
fi

: ${OPTIONS="$MODE -u $RM_USER -w $WK_DIR -v $MT_DIR:$ROOT -p $RM_PORT:3000 -e HOME=$ROOT -e U_WORKERS=$U_WORKERS -e U_ROOT=$U_ROOT $RE"}

$SUDO docker run $OPTIONS $RM_IMAGE $CMD

