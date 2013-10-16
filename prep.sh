RM_VERSION=2.3
RM_BRANCH=$RM_VERSION-stable
RM_URL=http://svn.redmine.org/redmine/branches/$RM_BRANCH
RM_DIR=redmine-$RM_VERSION
SVN_DIR=$RM_DIR/.svn

svn co $RM_URL $RM_DIR
rm -rf $SVN_DIR
cd $RM_DIR
git init
git add .
git ci -m "Initial commit"

