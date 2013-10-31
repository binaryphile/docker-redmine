#!/bin/bash

if [ -e .env ]; then
  source .env
fi

: ${GH_USER?"need to set github user GH_USER, see README.md"}
: ${RM_VERSION?"need to set redmine version RM_VERSION, see README.md"}
: ${RM_BASE?"need to set base image RM_BASE, see README.md"}

: ${RM_BRANCH=$RM_VERSION-stable}
: ${RM_URL=https://codeload.github.com/$GH_USER/redmine/tar.gz/$RM_BRANCH}
: ${ROOT=/root}
: ${OPTIONS="-i -t -v $(pwd):$ROOT -w $ROOT"}
: ${CMD=$ROOT/internal/install.sh}

rm -rf $RM_BRANCH
curl $RM_URL | tar -zxvf -
$SUDO docker run $OPTIONS $RM_BASE $CMD

