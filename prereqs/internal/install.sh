#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${ROOT=/root}
: ${SCMS="git mercurial"}
: ${DBS="libpq-dev postgresql-client libmysqlclient-dev mysql-client"}
: ${PREREQS="$SCMS $DBS imagemagick libmagickwand-dev libsqlite3-dev"}
: ${SOURCE_LIST="-o Dir::Etc::SourceList=$ROOT/sources.list"}
export DEBIAN_FRONTEND=noninteractive

apt-get $SOURCE_LIST update
apt-get $SOURCE_LIST install -y $PREREQS
apt-get clean

