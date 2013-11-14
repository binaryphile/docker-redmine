#!/bin/bash

if [ -e ".env" ]; then
  source .env
fi

: ${RM_IMAGE?"need to set base image RM_IMAGE, see README.md"}
: ${RM_VERSION?"need to set redmine version RM_VERSION, see README.md"}

: ${RM_BRANCH=$RM_VERSION-stable}
: ${RM_DIR=redmine-$RM_BRANCH}
: ${ROOT=/root}
: ${RM_USER=redmine}
: ${OPTIONS="-i -t -u $RM_USER -v $(pwd)/$RM_DIR:$ROOT -w $ROOT -e ROOT=$ROOT -e RAILS_ENV=$RAILS_ENV"}
: ${CMD=$ROOT/scripts/install-plugins.sh}

$SUDO docker run $OPTIONS $RM_IMAGE $CMD

