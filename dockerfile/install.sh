#!/bin/bash

if [ -e ".env" ]; then
  source .env
fi

: ${ROOT=/root}
: ${RM_DST=/redmine}

cd $ROOT
bundle install --without test --path .bundle
cp -R .bundle $RM_DST

