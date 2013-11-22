#!/bin/bash

if [ -e ".env" ]; then
  source .env
fi

: ${ROOT=/root}

cd $ROOT
if [ -v RAILS_ENV -a "$RAILS_ENV" == "production" ]; then
  export PGPASSWORD=$SU_PASS
  export PGUSER=$SU_USER
  export PGHOST=$DB_HOST
  psql template1 <<< "CREATE ROLE $DB_USER LOGIN ENCRYPTED PASSWORD '$DB_PASS' NOINHERIT VALID UNTIL 'infinity';"
  psql template1 <<< "CREATE DATABASE $DB_USER WITH ENCODING='UTF8' OWNER=$DB_USER;"
fi

