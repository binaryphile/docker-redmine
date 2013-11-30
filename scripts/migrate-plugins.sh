#!/bin/bash

if [[ -e .env ]]; then
  source .env
fi

: ${ROOT=/root}
: ${RM_BRANCH=$RM_VERSION-stable}
: ${RM_DIR=$ROOT/$RM_BRANCH}

cd $RM_DIR
bundle install
bundle exec rake redmine:plugins:migrate

