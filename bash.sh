#!/bin/bash

if [[ ! -e .env ]]; then
  cp sample.env .env
fi

source .env

: ${RM_IMAGE?"need to set image name RM_IMAGE, see README.md"}
: ${RM_VERSION?"need to set redmine version RM_VERSION, see README.md"}

if [[ ! -v ROOT ]]; then ROOT=/root; fi
if [[ ! -v RM_BRANCH ]]; then RM_BRANCH=$RM_VERSION-stable; fi
if [[ ! -v RM_DIR ]]; then RM_DIR=$RM_BRANCH; fi
if [[ ! -v RM_USER ]]; then RM_USER=redmine; fi
MT_DIR=$(pwd)
WK_DIR=$ROOT
CMD=/bin/bash

if [[ "$RAILS_ENV" == production ]]; then
  : ${DB_USER?"need to set database username DB_USER, see README.md"}
  : ${DB_PASS?"need to set database password DB_PASS, see README.md"}
  if [[ ! -v DB_HOST ]]; then DB_HOST=172.17.42.1; fi
  if [[ ! -v RM_PORT ]]; then RM_PORT=3001; fi
  DB="-e DB_HOST=$DB_HOST"
else
  if [[ ! -v RM_PORT ]]; then RM_PORT=3000; fi
fi

OPTIONS="-i -t -rm -u $RM_USER -w $WK_DIR -v $MT_DIR:$ROOT -p $RM_PORT:3000 -e HOME=$ROOT $DB"

$SUDO docker run $OPTIONS $RM_IMAGE $CMD

