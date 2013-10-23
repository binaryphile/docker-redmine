#!/bin/bash

: ${GH_USER?"need to set github user GH_USER, see README.md"}
: ${RM_VERSION?"need to set redmine version RM_VERSION, see README.md"}
: ${RM_BASE?"need to set base image RM_BASE, see README.md"}

: ${RM_BRANCH=$RM_VERSION-stable}
: ${RM_URL=https://codeload.github.com/$GH_USER/redmine/tar.gz/$RM_BRANCH}
: ${ROOT=/root}
: ${OPTIONS="-i -t -v $(pwd):$ROOT -w $ROOT -e ROOT=$ROOT -e RM_VERSION=$RM_VERSION -e GH_USER=$GH_USER"}
: ${CMD=$ROOT/install.sh}
: ${SUDO=""} # change to "sudo" if you aren't in the docker group

if [ ! -d "$RM_BRANCH" ]; then
  curl $RM_URL | tar -zxvf -
fi
$SUDO docker run $OPTIONS $RM_BASE $CMD

