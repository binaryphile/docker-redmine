#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${RM_DIR=/redmine}

cd $RM_DIR
source /usr/local/share/chruby/chruby.sh
chruby 2.0
bundle exec rake redmine:plugins:migrate
bundle exec rake db:migrate

