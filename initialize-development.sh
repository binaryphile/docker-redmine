#!/bin/bash

if [ -f .env ]; then
  source .env
fi

: ${RM_IMAGE?"need to set image name IMAGE, see README.md"}

: ${ROOT=/root}
: ${CMD=$ROOT/init.sh}
: ${RM_DIR=/redmine}
: ${OPTIONS="-i -t -w $RM_DIR -v $(pwd):$ROOT -e ROOT=$ROOT"}
: ${SUDO=""} # set to "sudo" if you are not in the docker group

$SUDO docker run $OPTIONS $RM_IMAGE $CMD

