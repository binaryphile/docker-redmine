#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${RM_BASE?"need to set base image RM_BASE, see README.md"}

: ${ROOT=/root}
: ${OPTIONS="-i -t -v $(pwd):$ROOT -w $ROOT"}
: ${CMD=$ROOT/install.sh}

$SUDO docker run $OPTIONS $RM_BASE $CMD

