#!/bin/bash

if [[ ! -e .env ]]; then
  cp sample.env .env
fi

source .env

: ${RM_VERSION?"need to set redmine version RM_VERSION, see README.md"}

if [[ ! -v ROOT ]]; then ROOT=/root; fi
if [[ ! -v RM_BRANCH ]]; then RM_BRANCH=$RM_VERSION-stable; fi
if [[ ! -v RM_DIR ]]; then RM_DIR=$RM_BRANCH; fi
if [[ ! -v RM_USER ]]; then RM_USER=redmine; fi
MT_DIR=$(pwd)
WK_DIR=$ROOT
OPTIONS="-i -t -rm -u $RM_USER -v $MT_DIR:$ROOT -w $WK_DIR -e HOME=$ROOT"
CMD=$ROOT/scripts/migrate-plugins.sh

$SUDO docker run $OPTIONS $RM_IMAGE $CMD

