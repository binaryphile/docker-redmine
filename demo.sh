#!/bin/bash

if [ ! -e .env ]; then
  cp sample.env .env
fi

./initialize.sh
./redmine.sh

