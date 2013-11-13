#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${ROOT=/root}

cd $ROOT
bundle exec rake db:migrate

