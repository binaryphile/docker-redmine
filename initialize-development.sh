#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${RM_IMAGE?"need to set image name IMAGE, see README.md"}

: ${ROOT=/root}
: ${RM_DIR=/redmine}
: ${OPTIONS="-i -t -w $ROOT -v $(pwd):$ROOT -e ROOT=$ROOT -e RM_DIR=$RM_DIR"}

$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/internal/init_host.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/internal/init_db.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/internal/load_default.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/internal/migrate.sh

