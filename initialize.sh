#!/bin/bash

if [ -e ".env" ]; then
  source .env
fi

: ${RM_IMAGE?"need to set image name RM_IMAGE, see README.md"}
: ${RM_VERSION?"need to set redmine version RM_VERSION, see README.md"}
: ${GH_USER?"need to set github user GH_USER, see README.md"}

: ${ROOT=/root}
: ${RM_BRANCH=$RM_VERSION-stable}
: ${RM_DIR=$RM_BRANCH}
: ${MT_DIR=$(pwd)/$RM_DIR}
: ${WK_DIR=$ROOT/$RM_DIR}
: ${RM_URL=git://github.com/$GH_USER/redmine}
: ${RM_USER=redmine}

if [ -v RAILS_ENV -a "$RAILS_ENV" == "production" ]; then
  : ${DB_USER?"need to set database username DB_USER, see README.md"}
  : ${DB_PASS?"need to set database password DB_PASS, see README.md"}
  : ${SU_USER?"need to set database superuser name SU_USER, see README.md"}
  : ${SU_PASS?"need to set database superuser password SU_PASS, see README.md"}

  : ${DB_ADAPTER=postgresql}
  : ${DB_DATABASE=redmine}
  : ${DB_HOST=172.17.42.1}
  : ${OPTIONS="-i -t -u $RM_USER -w $WK_DIR -v $MT_DIR:$ROOT -e HOME=$ROOT -e ROOT=$ROOT -e RAILS_ENV=$RAILS_ENV -e DB_ADAPTER=$DB_ADAPTER -e DB_DATABASE=$DB_DATABASE -e DB_HOST=$DB_HOST -e DB_USER=$DB_USER -e DB_PASS=$DB_PASS -e SU_PASS=$SU_PASS -e SU_USER=$SU_USER"}
else
  : ${OPTIONS="-i -t -u $RM_USER -w $WK_DIR -v $MT_DIR:$ROOT -e HOME=$ROOT -e ROOT=$ROOT"}
fi

if [ -d $RM_DIR ]; then
  cd $RM_DIR
  git pull
  cd ..
else
  git clone -b $RM_BRANCH $RM_URL $RM_DIR
fi

$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/initialize.sh

