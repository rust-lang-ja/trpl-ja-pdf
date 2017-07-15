#!/usr/bin/env bash

# This script commits trpl submodule's revision if it has been chaned, and
# pushes the commit to the remote repository.

set -e

TRPL_DIR=the-rust-programming-language-ja

# Get the revision of trpl submodule.
REVISION=$(cd ${TRPL_DIR}; git rev-parse --short HEAD)

git add ${TRPL_DIR}

set +e
ret=$(git status | grep -q 'Changes to be committed:'; echo $?)
set -e

if [ $ret -eq 0 ] ; then
    git commit -m "auto commit on travis ${TRAVIS_JOB_NUMBER} [ci skip]\n\nupdate trpl submodule to ${REVISION}."
    echo "Comitting trpl submodule's new revision ${REVISION}."
    git push origin master
else
    echo "There is no change in trpl submodule. (revision: ${REVISION})"
fi
