#!/bin/bash

if [ -e ".env" ]; then
  source .env
fi

: ${RM_IMAGE?"need to set image name IMAGE, see README.md"}
: ${DB_USER?"need to set database username DB_USER, see README.md"}
: ${DB_PASS?"need to set database password DB_PASS, see README.md"}
: ${RM_VERSION?"need to set redmine version RM_VERSION, see README.md"}

: ${RM_BRANCH=$RM_VERSION-stable}
: ${RM_DIR=redmine-$RM_BRANCH}
: ${ROOT=/root}
: ${RM_PORT=3000}
: ${RM_USER=redmine}
: ${CMD=/bin/bash}
: ${RM_DIR=/redmine}
: ${OPTIONS="-i -t -u $RM_USER -w $ROOT -v $(pwd)/$RM_DIR:$ROOT -p $RM_PORT:3000 -e ROOT=$ROOT -e HOME=$ROOT -e RAILS_ENV=$RAILS_ENV -e DB_ADAPTER=$DB_ADAPTER -e DB_DATABASE=$DB_DATABASE -e DB_HOST=$DB_HOST -e DB_USER=$DB_USER -e DB_PASS=$DB_PASS -e SU_USER=$SU_USER -e SU_PASS=$SU_PASS"}

$SUDO docker run $OPTIONS $RM_IMAGE $CMD

