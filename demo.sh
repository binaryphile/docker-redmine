#!/bin/bash
: ${RM_IMAGE?"need to set redmine image RM_IMAGE, see README.md"}

: ${ROOT=/root}
: ${RM_PORT=3000}
: ${CMD="bundle exec rails s"}
: ${RM_DIR=/redmine}
: ${OPTIONS="-i -t -w $RM_DIR -v $(pwd):$ROOT -e ROOT=$ROOT -p $RM_PORT:3000"}
: ${SUDO=""} # set to "sudo" if you are not in the docker group

$SUDO docker run $OPTIONS $RM_IMAGE $CMD

