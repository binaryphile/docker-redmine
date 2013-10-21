#!/bin/sh

ROOT=/root
GH_USER=binaryphile
RM_VERSION=2.3
SCMS="git mercurial"
ROOT_SRC=$ROOT/redmine-$RM_VERSION-stable
RM_DST=/redmine
RM_CONF_DIR=$RM_DST/config
RM_FILES_DIR=$RM_DST/files
ROOT_FILES_DIR=$ROOT/files
RM_LOG_DIR=$RM_DST/log
ROOT_LOG_DIR=$ROOT/log
RM_PIASSETS_DIR=$RM_DST/public/plugin_assets
U_PID_DIR=$RM_DST/pids

SOURCE_LIST="-o Dir::Etc::SourceList=$ROOT/sources.list"
export DEBIAN_FRONTEND=noninteractive

apt-get $SOURCE_LIST update
apt-get $SOURCE_LIST install -y $SCMS imagemagick libmagickwand-dev libsqlite3-dev libmysqlclient-dev libpq-dev
cp -R $ROOT_SRC $RM_DST
rm -rf $RM_FILES_DIR
ln -s $ROOT_FILES_DIR $RM_FILES_DIR
rm -rf $RM_LOG_DIR
ln -s $ROOT_LOG_DIR $RM_LOG_DIR
mkdir -p $RM_PIASSETS_DIR
mkdir -p $U_PID_DIR
cd $RM_DST
bundle install --without development test
bundle exec rake generate_secret_token

apt-get clean

