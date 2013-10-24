#!/bin/bash

: ${RM_IMAGE?"need to set image name IMAGE, see README.md"}
: ${DB_USER?"need to set database username DB_USER, see README.md"}
: ${DB_PASS?"need to set database password DB_PASS, see README.md"}

: ${ROOT=/root}
: ${RAILS_ENV=production}
: ${DB_ADAPTER=postgresql}
: ${DB_DATABASE=redmine}
: ${DB_HOST=172.17.42.1}
#: ${CMD=/bin/bash}
: ${CMD=$ROOT/init.sh}
: ${RM_DIR=/redmine}
: ${OPTIONS="-i -t -w $RM_DIR -v $(pwd):$ROOT -e ROOT=$ROOT -e RAILS_ENV=$RAILS_ENV -e DB_ADAPTER=$DB_ADAPTER -e DB_DATABASE=$DB_DATABASE -e DB_HOST=$DB_HOST -e DB_USER=$DB_USER -e DB_PASS=$DB_PASS -e SU_PASS=$SU_PASS -e SU_USER=$SU_USER"}
: ${SUDO=""} # set to "sudo" if you are not in the docker group

$SUDO docker run $OPTIONS $RM_IMAGE $CMD

