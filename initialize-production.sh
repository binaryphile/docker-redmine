#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${RM_IMAGE?"need to set image name IMAGE, see README.md"}
: ${DB_USER?"need to set database username DB_USER, see README.md"}
: ${DB_PASS?"need to set database password DB_PASS, see README.md"}
: ${SU_USER?"need to set database superuser name SU_USER, see README.md"}
: ${SU_PASS?"need to set database superuser password SU_PASS, see README.md"}

: ${ROOT=/root}
: ${RAILS_ENV=production}
: ${RM_USER=redmine}
: ${DB_ADAPTER=postgresql}
: ${DB_DATABASE=redmine}
: ${DB_HOST=172.17.42.1}
: ${RM_DIR=/redmine}
: ${OPTIONS="-i -t -u $RM_USER -w $RM_DIR -v $(pwd)/local:$ROOT -e ROOT=$ROOT -e RAILS_ENV=$RAILS_ENV -e DB_ADAPTER=$DB_ADAPTER -e DB_DATABASE=$DB_DATABASE -e DB_HOST=$DB_HOST -e DB_USER=$DB_USER -e DB_PASS=$DB_PASS -e SU_PASS=$SU_PASS -e SU_USER=$SU_USER"}

$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/init-host.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/init-db.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/init-migrate.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/load-default.sh
$SUDO docker run $OPTIONS $RM_IMAGE $ROOT/scripts/install-plugins.sh


