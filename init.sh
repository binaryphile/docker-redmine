#!/bin/sh

ROOT=/root
ROOT_FILES_DIR=$ROOT/files
ROOT_LOG_DIR=$ROOT/log
RM_DIR=/redmine
export REDMINE_LANG=en

mkdir -p $ROOT_FILES_DIR
mkdir -p $ROOT_LOG_DIR
cd $RM_DIR
bundle exec rake db:migrate
bundle exec rake redmine:load_default_data

