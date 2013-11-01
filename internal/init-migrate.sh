#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${RM_DIR=/redmine}

cd $RM_DIR
bundle exec rake db:migrate

