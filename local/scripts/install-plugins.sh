#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${RM_DIR=/redmine}
: ${ROOT=/root}

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
if [ -d "$ROOT/public" ]; then
  rm -rf public
else
  mv public $ROOT
fi
ln -s $ROOT/public public
bundle install
bundle exec rake redmine:plugins:migrate
bundle exec rake db:migrate

