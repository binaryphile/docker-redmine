#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${RM_IMAGE?"need to set image name IMAGE, see README.md"}

: ${ROOT=/root}
: ${RM_DIR=/redmine}
: ${OPTIONS="-i -t -w $ROOT -v $(pwd)/local:$ROOT -e ROOT=$ROOT -e RM_DIR=$RM_DIR"}

$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/init-host.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/init-db.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/init-migrate.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/load-default.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/migrate.sh

