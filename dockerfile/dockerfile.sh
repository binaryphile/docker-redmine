#!/bin/bash

if [ -e ".env" ]; then
  source .env
fi

: ${GH_USER?"need to set github user GH_USER, see README.md"}
: ${RM_VERSION?"need to set redmine version RM_VERSION, see README.md"}
: ${RM_BASE?"need to set base image RM_BASE, see README.md"}

: ${RM_BRANCH=$RM_VERSION-stable}
: ${RM_DIR=redmine-$RM_BRANCH}
: ${RM_URL=https://codeload.github.com/$GH_USER/redmine/tar.gz/$RM_BRANCH}
: ${RM_USER=redmine}
: ${ROOT=/root}
: ${RM_DIR=/redmine}
: ${OPTIONS="-i -t -u $RM_USER -v $(pwd)/$RM_DIR:$ROOT -w $ROOT"}
: ${CMD=$ROOT/install.sh}

rm -rf $RM_DIR
curl $RM_URL | tar -zxvf -
cp install.sh $RM_DIR
$SUDO docker run $OPTIONS $RM_BASE $CMD

