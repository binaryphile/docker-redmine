#!/bin/bash

if [ -e ".env" ]; then
  source .env
fi

: ${RM_IMAGE?"need to set image name RM_IMAGE, see README.md"}
: ${RM_VERSION?"need to set redmine version RM_VERSION, see README.md"}

: ${ROOT=/root}
: ${RM_BRANCH=$RM_VERSION-stable}
: ${RM_DIR=$RM_BRANCH}
: ${MT_DIR=$(pwd)}
: ${WK_DIR=$ROOT}
: ${RM_USER=redmine}
: ${CMD=/bin/bash}

if [ -v RAILS_ENV -a "$RAILS_ENV" == "production" ]; then
  : ${DB_USER?"need to set database username DB_USER, see README.md"}
  : ${DB_PASS?"need to set database password DB_PASS, see README.md"}

  : ${DB_ADAPTER=postgresql}
  : ${DB_DATABASE=redmine}
  : ${DB_HOST=172.17.42.1}
  : ${RM_PORT=3001}
else
  : ${RM_PORT=3000}
fi

: ${OPTIONS="-i -t -u $RM_USER -w $WK_DIR -v $MT_DIR:$ROOT -p $RM_PORT:3000 -e HOME=$ROOT"}

$SUDO docker run $OPTIONS $RM_IMAGE $CMD

