#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${RM_IMAGE?"need to set redmine image RM_IMAGE, see README.md"}
: ${RM_VERSION?"need to set redmine version RM_VERSION, see README.md"}

: ${RM_BRANCH=$RM_VERSION-stable}
: ${RM_DIR=redmine-$RM_BRANCH}
: ${ROOT=/root}
: ${RM_PORT=3000}
: ${RM_USER=redmine}
: ${CMD="bundle exec rails s"}
: ${OPTIONS="-i -t -u $RM_USER -w $ROOT -v $(pwd)/$RM_DIR:$ROOT -e ROOT=$ROOT -e HOME=$ROOT -p $RM_PORT:3000"}

$SUDO docker run $OPTIONS $RM_IMAGE $CMD

