#!/bin/sh
ROOT=/root
IMAGE=binaryphile/redmine:2.3-stable
DB_ADAPTER=postgresql
DB_DATABASE=redmine
DB_HOST=192.168.1.2
DB_USERNAME=redmine
DB_PASSWORD=Redmi42.postgresql.
RAILS_ENV=production
RM_PORT=3001
CMD="bundle exec unicorn_rails -c config/unicorn.rb -p $RM_PORT"
RM_DIR=/redmine
OPTIONS="-d -w $RM_DIR -v $(pwd):$ROOT -p :$RM_PORT -e RAILS_ENV=$RAILS_ENV -e DB_ADAPTER=$DB_ADAPTER -e DB_DATABASE=$DB_DATABASE -e DB_HOST=$DB_HOST -e DB_USERNAME=$DB_USERNAME -e DB_PASSWORD=$DB_PASSWORD"
SUDO=""

$SUDO docker run $OPTIONS $IMAGE $CMD

