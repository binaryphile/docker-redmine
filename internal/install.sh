#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: {RM_VERSION?"need to set redmine version RM_VERSION, see README.md"}

: ${ROOT=/root}
: ${ROOT_SRC=$ROOT/redmine-$RM_VERSION-stable}
: ${RM_DST=/redmine}
: ${RM_CONF_DIR=$RM_DST/config}
: ${RM_FILES_DIR=$RM_DST/files}
: ${ROOT_FILES_DIR=$ROOT/files}
: ${RM_LOG_DIR=$RM_DST/log}
: ${ROOT_LOG_DIR=$ROOT/log}
: ${RM_PIASSETS_DIR=$RM_DST/public/plugin_assets}
: ${U_PID_DIR=$RM_DST/pids}

rm -rf $RM_DST
cp -R $ROOT_SRC $RM_DST
rm -rf $RM_FILES_DIR
ln -s $ROOT_FILES_DIR $RM_FILES_DIR
rm -rf $RM_LOG_DIR
ln -s $ROOT_LOG_DIR $RM_LOG_DIR
ln -s $ROOT/config/initializers/secret_token.rb $RM_DST/config/initializers/secret_token.rb
ln -s $ROOT/.env $RM_DST/.env
mkdir -p $RM_PIASSETS_DIR
mkdir -p $U_PID_DIR
cd $RM_DST
bundle install --without test

