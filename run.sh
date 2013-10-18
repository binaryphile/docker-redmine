#!/bin/sh
ROOT=/root
IMAGE=binaryphile/redmine:2.3-stable

docker run -i -t -v $(pwd):$ROOT -p :3000 -e HOME=$ROOT $IMAGE /bin/bash

