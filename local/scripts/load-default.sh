#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: {$RM_DIR=/redmine}
export REDMINE_LANG=en

cd $RM_DIR
source /usr/local/share/chruby/chruby.sh
chruby 2.0
bundle exec rake redmine:load_default_data

