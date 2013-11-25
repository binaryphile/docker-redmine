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
  : ${DB_ADAPTER=postgresql}
  : ${DB_DATABASE=redmine}
  : ${DB_HOST=172.17.42.1}
  : ${RAILS_ENV=production}
  : ${U_WORKERS=2}
  : ${RM_PORT=3001}
  : ${CMD="bundle exec unicorn_rails -c config/unicorn.rb"}
else
  : ${RM_PORT=3000}
  : ${CMD="bundle exec rails s"}
fi

: ${OPTIONS="-i -t -u $RM_USER -w $WK_DIR -v $MT_DIR:$ROOT -p $RM_PORT:3000 -e HOME=$ROOT"}

$SUDO docker run $OPTIONS $RM_IMAGE $CMD

