#!/bin/bash

if [ -e ".env" ]; then
  source .env
fi

: {$ROOT=/root}
export REDMINE_LANG=en

cd $ROOT
bundle exec rake redmine:load_default_data

