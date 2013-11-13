#!/bin/bash

if [ -e ".env" ]; then
  source .env
fi

: ${GH_USER?"need to set github user GH_USER, see README.md"}
: ${RM_VERSION?"need to set redmine version RM_VERSION, see README.md"}
: ${RM_BASE?"need to set base image RM_BASE, see README.md"}

: ${RM_BRANCH=$RM_VERSION-stable}
: ${RM_URL=https://codeload.github.com/$GH_USER/redmine/tar.gz/$RM_BRANCH}
: ${RM_USER=redmine}
: ${ROOT=/root}
: ${RM_DIR=/redmine}
: ${OPTIONS="-i -t -u $RM_USER -v $(pwd):$ROOT -w $ROOT"}
: ${CMD=$ROOT/install.sh}

rm -rf $RM_BRANCH
curl $RM_URL | tar -zxvf -
$SUDO docker run $OPTIONS $RM_BASE $CMD

