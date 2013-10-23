#!/bin/bash
: ${RM_IMAGE?"need to set redmine image RM_IMAGE, see README.md"}

: ${ROOT=/root}
: ${RAILS_ENV=development}
: ${RM_PORT=3000}
: ${CMD="bundle exec rails s"}
: ${RM_DIR=/redmine}
: ${OPTIONS="-i -t -w $RM_DIR -v $(pwd):$ROOT -p $RM_PORT:3000 -e RAILS_ENV=$RAILS_ENV"}
: ${SUDO=""} # set to "sudo" if you are not in the docker group

$SUDO docker run $OPTIONS $RM_IMAGE $CMD

