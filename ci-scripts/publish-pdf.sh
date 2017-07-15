#!/usr/bin/env bash

# This script checks if this build was performed on the `master` branch,
# and if so, it pushes the PDF files to `origin/gh-pages` branch.

set -e

function current_branch() {
    local branch
    if [ "x_{$EVENT_TYPE}" = "x_pull_request" ]; then
        branch=${TRAVIS_PULL_REQUEST_BRANCH}
    else
        branch=${TRAVIS_BRANCH}
    fi

    if [ "x_${branch}" = "x_" ]; then
        echo "TRAVIS_*BRANCH variable(s) seem undefined. Could not determin the branch." 1>&2
        return 1
    else
        echo ${branch}
        return 0
    fi
}

function push_files_to_gh_pages() {
    git fetch origin gh-pages:gh-pages
    git stash -u
    git checkout gh-pages
    rm a4.pdf letter.pdf
    git stash pop
    git add a4.pdf letter.pdf
    git commit -a -m "auto commit on travis $TRAVIS_JOB_NUMBER $TRAVIS_COMMIT [ci skip]"
    echo "Pushing the PDF files to gh-pages branch."
    git push origin gh-pages:gh-pages
}

if [ "x_${TRAVIS}" != "x_true" ]; then
    echo "Not pushing the PDF files to gh-pages because this script was not triggered by Travis CI." 1>&2
    exit 1
else
    CURRENT_BRANCH=$(current_branch)
    if [ "x_${CURRENT_BRANCH}" = "x_master" ]; then
        push_files_to_gh_pages
    else
        echo "Not pushing the PDF files to gh-pages because the current branch ${CURRENT_BRANCH} is not master branch."
    fi
fi
