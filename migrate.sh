#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${RM_IMAGE?"need to set base image RM_IMAGE, see README.md"}

: ${ROOT=/root}
: ${RM_DIR=/redmine}
: ${OPTIONS="-i -t -v $(pwd)/local:$ROOT -w $RM_DIR -e ROOT=$ROOT"}
: ${CMD=$ROOT/scripts/migrate.sh}

$SUDO docker run $OPTIONS $RM_IMAGE $CMD

