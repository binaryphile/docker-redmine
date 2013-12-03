#!/bin/bash

initialize () {

  : ${GH_USER?"need to set github user GH_USER, see README.md"}

  if [[ ! -v RM_URL ]]; then local RM_URL=git://github.com/$GH_USER/redmine; fi
  local OPTIONS="-i -t -rm -u $RM_USER -w $WK_DIR -v $MT_DIR:$ROOT -e HOME=$ROOT"
  local CMD=$ROOT/scripts/initialize.sh

  if [[ -d "$RM_DIR" ]]; then
    cd $RM_DIR
    git pull
    cd ..
  else
    git clone -b $RM_BRANCH $RM_URL $RM_DIR
    ln -s ../.env $RM_DIR/.env
  fi

  $SUDO docker run $OPTIONS $RM_IMAGE $CMD

}

redmine () {

  if [[ "$RAILS_ENV" == production ]]; then
    if [[ ! -v RM_PORT ]]; then local RM_PORT=3001; fi
    if [[ ! -v DB_HOST ]]; then local DB_HOST=172.17.42.1; fi
    local MODE=-d
    local RE="-e RAILS_ENV=$RAILS_ENV"
    local UW="-e U_WORKERS=$U_WORKERS"
    local DB="-e DB_HOST=$DBHOST"
    local CMD="bundle exec unicorn_rails -c config/unicorn.rb"
  else
    if [[ ! -v RM_PORT ]]; then local RM_PORT=3000; fi
    local MODE="-i -t -rm"
    local CMD="bundle exec rails s"
  fi

  local OPTIONS="$MODE -u $RM_USER -w $WK_DIR -v $MT_DIR/$RM_DIR:$ROOT -p $RM_PORT:3000 -e HOME=$ROOT $RE $UW $DB"

  $SUDO docker run $OPTIONS $RM_IMAGE $CMD

}

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

if [[ ! -v RAILS_ENV || "$RAILS_ENV" == development ]]; then
  if [[ ! -e $RM_DIR/db/development.sqlite3 ]]; then
    initialize
  fi
else
  if [[ "$RAILS_ENV" == production && ! -e .production ]]; then
    initialize
  fi
fi

redmine

