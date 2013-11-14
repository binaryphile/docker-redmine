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
: ${RM_USER=redmine}
: ${DB_ADAPTER=postgresql}
: ${DB_DATABASE=redmine}
: ${DB_HOST=172.17.42.1}
: ${RAILS_ENV=production}
: ${U_WORKERS=2}
: ${RM_PORT=3001}
: ${CMD="bundle exec unicorn_rails -c config/unicorn.rb"}
: ${OPTIONS="-d -u $RM_USER -w $ROOT -v $(pwd)/$RM_DIR:$ROOT -p $RM_PORT:3001 -e RAILS_ENV=$RAILS_ENV -e U_WORKERS=$U_WORKERS -e DB_ADAPTER=$DB_ADAPTER -e DB_DATABASE=$DB_DATABASE -e DB_HOST=$DB_HOST -e DB_USER=$DB_USER -e DB_PASS=$DB_PASS"}

$SUDO docker run $OPTIONS $RM_IMAGE $CMD

