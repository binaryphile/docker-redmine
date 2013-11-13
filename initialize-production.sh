#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${RM_IMAGE?"need to set image name IMAGE, see README.md"}
: ${DB_USER?"need to set database username DB_USER, see README.md"}
: ${DB_PASS?"need to set database password DB_PASS, see README.md"}
: ${SU_USER?"need to set database superuser name SU_USER, see README.md"}
: ${SU_PASS?"need to set database superuser password SU_PASS, see README.md"}
: ${GH_USER?"need to set github user GH_USER, see README.md"}
: ${RM_VERSION?"need to set redmine version RM_VERSION, see README.md"}

: ${RM_BRANCH=$RM_VERSION-stable}
: ${RM_DIR=redmine-$RM_BRANCH}
: ${RM_URL=https://codeload.github.com/$GH_USER/redmine/tar.gz/$RM_BRANCH}
: ${ROOT=/root}
: ${RAILS_ENV=production}
: ${RM_USER=redmine}
: ${DB_ADAPTER=postgresql}
: ${DB_DATABASE=redmine}
: ${DB_HOST=172.17.42.1}
: ${RM_DIR=/redmine}
: ${OPTIONS="-i -t -u $RM_USER -w $ROOT -v $(pwd)/$RM_DIR:$ROOT -e ROOT=$ROOT -e RAILS_ENV=$RAILS_ENV -e DB_ADAPTER=$DB_ADAPTER -e DB_DATABASE=$DB_DATABASE -e DB_HOST=$DB_HOST -e DB_USER=$DB_USER -e DB_PASS=$DB_PASS -e SU_PASS=$SU_PASS -e SU_USER=$SU_USER"}

curl $RM_URL | tar -zxvf -
cp -R scripts $RM_DIR
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/init-host.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/init-db.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/init-migrate.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/load-default.sh
cp -R plugins $RM_DIR
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/install-plugins.sh
cp .env $RM_DIR

