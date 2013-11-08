#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${RM_IMAGE?"need to set image name RM_IMAGE, see README.md"}

: ${ROOT=/root}
: ${RM_DIR=/redmine}
: ${RM_USER=redmine}
: ${OPTIONS="-i -t -u $RM_USER -w $ROOT -v $(pwd)/local:$ROOT -e HOME=$ROOT -e ROOT=$ROOT -e RM_DIR=$RM_DIR"}

$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/init-host.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/init-db.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/init-migrate.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/load-default.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/migrate.sh

