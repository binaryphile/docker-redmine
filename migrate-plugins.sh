#!/bin/bash

if [ -e ".env" ]; then
  source .env
fi

: ${RM_VERSION?"need to set redmine version RM_VERSION, see README.md"}

: ${ROOT=/root}
: ${RM_BRANCH=$RM_VERSION-stable}
: ${RM_DIR=$RM_BRANCH}
: ${MT_DIR=$(pwd)}
: ${WK_DIR=$ROOT}
: ${RM_USER=redmine}
: ${OPTIONS="-i -t -u $RM_USER -v $MT_DIR:$ROOT -w $WK_DIR -e HOME=$ROOT"}
: ${CMD=$ROOT/scripts/install-plugins.sh}

$SUDO docker run $OPTIONS $RM_IMAGE $CMD

