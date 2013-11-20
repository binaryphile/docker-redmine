#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${RM_IMAGE?"need to set image name RM_IMAGE, see README.md"}
: ${GH_USER?"need to set github user GH_USER, see README.md"}
: ${RM_VERSION?"need to set redmine version RM_VERSION, see README.md"}

: ${RM_BRANCH=$RM_VERSION-stable}
: ${RM_DIR=redmine-$RM_BRANCH}
: ${RM_URL=git://github.com/$GH_USER/redmine}
: ${ROOT=/root}
: ${RM_USER=redmine}
: ${OPTIONS="-i -t -u $RM_USER -w $ROOT -v $(pwd)/$RM_DIR:$ROOT -e HOME=$ROOT -e ROOT=$ROOT"}

git clone -b $RM_BRANCH $RM_URL $RM_DIR
cp -R scripts $RM_DIR
cp .env $RM_DIR
cd $RM_DIR
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/init-host.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/init-db.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/init-migrate.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/load-default.sh

