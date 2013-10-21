#!/bin/sh
: ${IMAGE?"need to set image name IMAGE, see README.md"}
: ${DB_HOST?"need to set database hostname or ip DB_HOST, see README.md"}
: ${DB_USERNAME?"need to set database username DB_USERNAME, see README.md"}
: ${DB_PASSWORD?"need to set database password DB_PASSWORD, see README.md"}

: ${ROOT=/root}
: ${DB_ADAPTER=postgresql}
: ${DB_DATABASE=redmine}
: ${RAILS_ENV=production}
: ${RM_PORT=3001}
: ${CMD=/bin/bash}
: ${RM_DIR=/redmine}
: ${OPTIONS="-i -t -w $RM_DIR -v $(pwd):$ROOT -p :$RM_PORT -e RAILS_ENV=$RAILS_ENV -e DB_ADAPTER=$DB_ADAPTER -e DB_DATABASE=$DB_DATABASE -e DB_HOST=$DB_HOST -e DB_USERNAME=$DB_USERNAME -e DB_PASSWORD=$DB_PASSWORD"}
: ${SUDO=""} # set to "sudo" if you are not in the docker group

$SUDO docker run $OPTIONS $IMAGE $CMD

