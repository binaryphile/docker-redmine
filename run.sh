#!/bin/sh
ROOT=/root
IMAGE=binaryphile/ruby:2.0.0-p247

docker run -i -t -v $(pwd):$ROOT -e HOME=$ROOT $IMAGE /bin/bash

