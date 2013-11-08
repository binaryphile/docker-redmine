#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${RM_IMAGE?"need to set redmine image RM_IMAGE, see README.md"}

: ${ROOT=/root}
: ${RM_PORT=3000}
: ${RM_USER=redmine}
: ${CMD="source /usr/local/share/chruby/chruby.sh && chruby 2.0 && bundle exec rails s"}
: ${RM_DIR=/redmine}
: ${OPTIONS="-i -t -u $RM_USER -w $RM_DIR -v $(pwd)/local:$ROOT -e ROOT=$ROOT -p $RM_PORT:3000"}

$SUDO docker run $OPTIONS $RM_IMAGE $CMD

