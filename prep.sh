RM_VERSION=2.3
RM_BRANCH=$RM_VERSION-stable
GH_USER=binaryphile
RM_URL=https://codeload.github.com/$GH_USER/redmine/tar.gz/$RM_BRANCH

curl $RM_URL | tar -zxvf -

