# Single-serving Redmine Docker image

## Description

Generates a Docker image for [Redmine].

Before you go building Redmine 2.3-stable, you can use my image by
running:

    docker pull binaryphile/redmine:2.3-stable

## Usage

If you don't have a copy of Redmine's source already, you can use
`prep.sh` to download the latest copy and initialize your own git
repository.  You'll need [subversion] installed on your machine so the
source can be downloaded from the Redmine svn server.  

The reason I suggest using a git repo

[Redmine]: http://www.redmine.org/
[subversion]: http://?/

