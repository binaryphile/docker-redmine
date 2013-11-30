#!/bin/bash

initialize () {

  if [[ "$RAILS_ENV" == production ]]; then
    : ${DB_USER?"need to set database username DB_USER, see README.md"}
    : ${DB_PASS?"need to set database password DB_PASS, see README.md"}
    : ${SU_USER?"need to set database superuser name SU_USER, see README.md"}
    : ${SU_PASS?"need to set database superuser password SU_PASS, see README.md"}
  fi

  : ${OPTIONS="-i -t -rm -u $RM_USER -w $WK_DIR -v $MT_DIR:$ROOT -e HOME=$ROOT"}
  : ${CMD=$ROOT/scripts/initialize.sh}

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
    : ${RM_PORT=3001}
    : ${MODE=-d}
    : ${RE="-e RAILS_ENV=$RAILS_ENV"}
    : ${UW="-e U_WORKERS=$U_WORKERS"}
    : ${CMD="bundle exec unicorn_rails -c config/unicorn.rb"}
  else
    : ${RM_PORT=3000}
    : ${MODE="-i -t -rm"}
    : ${CMD="bundle exec rails s"}
  fi

  : ${OPTIONS="$MODE -u $RM_USER -w $WK_DIR -v $MT_DIR/$RM_DIR:$ROOT -p $RM_PORT:3000 -e HOME=$ROOT $RE $UW"}

  $SUDO docker run $OPTIONS $RM_IMAGE $CMD

}

if [[ ! -e .env ]]; then
  cp sample.env .env
fi

source .env

: ${RM_IMAGE?"need to set image name RM_IMAGE, see README.md"}
: ${RM_VERSION?"need to set redmine version RM_VERSION, see README.md"}
: ${GH_USER?"need to set github user GH_USER, see README.md"}

: ${ROOT=/root}
: ${RM_BRANCH=$RM_VERSION-stable}
: ${RM_DIR=$RM_BRANCH}
: ${MT_DIR=$(pwd)}
: ${WK_DIR=$ROOT}
: ${RM_URL=git://github.com/$GH_USER/redmine}
: ${RM_USER=redmine}

if [[ ! -v RAILS_ENV || "$RAILS_ENV" == development ]]; then
  if [[ ! -e $RM_DIR/db/development.sqlite ]]; then
    initialize
  fi
else
  if [[ "$RAILS_ENV" == production && ! -e .production ]]; then
    initialize
  fi
fi

redmine

