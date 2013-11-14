#!/bin/bash

if [ -e ".env" ]; then
  source .env
fi

: ${ROOT=/root}

cd $ROOT
bundle install
bundle exec rake redmine:plugins:migrate

