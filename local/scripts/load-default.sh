#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: {$RM_DIR=/redmine}
export REDMINE_LANG=en

cd $RM_DIR
if [ -e "$ROOT/Gemfile.lock" ]; then
  rm Gemfile.lock
else
  mv Gemfile.lock $ROOT
fi
ln -s $ROOT/Gemfile.lock Gemfile.lock
if [ -d "$ROOT/.bundle" ]; then
  rm -rf .bundle
else
  mv .bundle $ROOT/.bundle
fi
ln -s $ROOT/.bundle .bundle
bundle exec rake redmine:load_default_data

