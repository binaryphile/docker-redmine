#!/bin/bash

if [[ -e .env ]]; then
  source .env
fi

if [[ "$RAILS_ENV" == production ]]; then
  : ${DB_USER?"need to set database username DB_USER, see README.md"}
  : ${DB_PASS?"need to set database password DB_PASS, see README.md"}
  if [[ ! -v DB_HOST ]]; then 
fi

if [[ ! -v ROOT ]]; then ROOT=/root; fi
if [[ ! -v RM_BRANCH ]]; then RM_BRANCH=$RM_VERSION-stable; fi
if [[ ! -v RM_DIR ]]; then RM_DIR=$ROOT/$RM_BRANCH; fi

cd $RM_DIR
bundle install
bundle exec rake redmine:plugins:migrate

