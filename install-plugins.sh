#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${RM_IMAGE?"need to set base image RM_IMAGE, see README.md"}

: ${ROOT=/root}
: ${RM_DIR=/redmine}
: ${RM_USER=redmine}
: ${OPTIONS="-i -t -u $RM_USER -v $(pwd)/local:$ROOT -w $RM_DIR -e ROOT=$ROOT"}
: ${CMD=$ROOT/scripts/install-plugins.sh}

$SUDO docker run $OPTIONS $RM_IMAGE $CMD

