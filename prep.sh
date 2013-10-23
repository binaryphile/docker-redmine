#!/bin/bash

: ${GH_USER?"need to set github user GH_USER, see README.md"}

: ${RM_VERSION=2.3}
: ${RM_BRANCH=$RM_VERSION-stable}
: ${RM_URL=https://codeload.github.com/$GH_USER/redmine/tar.gz/$RM_BRANCH}

if [ ! -d $RM_BRANCH ]; then
  curl $RM_URL | tar -zxvf -
fi

