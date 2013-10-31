#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${RM_BASE?"need to set base image RM_BASE, see README.md"}

: ${ROOT=/root}
: ${RM_DIR=/redmine}
: ${OPTIONS="-i -t -v $(pwd):$ROOT -w $RM_DIR -e ROOT=$ROOT"}
: ${CMD=$ROOT/internal/migrate.sh}

$SUDO docker run $OPTIONS $RM_BASE $CMD

