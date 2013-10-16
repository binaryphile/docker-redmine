#!/bin/sh

RM_DIR=/redmine
export REDMINE_LANG=en
export RAILS_ENV=development

cd $RM_DIR
bundle exec rake db:migrate
bundle exec rake redmine:load_default_data

