#!/usr/bin/env bash

# This script checks if this build was performed on the `master` branch,
# and if so, it pushes the PDF files to `origin/gh-pages` branch.
#
# Requires: `bash` -- because `local` and `pipefail` are used.

set -u -e -o pipefail

source ./ci-scripts/common-lib

function push_pdf_files_to_gh_pages() {
    git fetch origin gh-pages:gh-pages
    git stash -u
    git checkout gh-pages
    rm a4.pdf letter.pdf
    git stash pop
    git add a4.pdf letter.pdf
    git commit -a -m "auto commit on travis $TRAVIS_JOB_NUMBER $TRAVIS_COMMIT [ci skip]"
    local remote_url
    remote_url=$(get_remote_ssh_repo_url)
    echo "Pushing the PDF files to gh-pages branch of ${remote_url}."
    git push ${remote_url} gh-pages:gh-pages
}

exit_if_not_ci

if [ -z "${TRAVIS+x}"  -o "x_${TRAVIS}" != "x_true" ]; then
    echo "ERROR: Not pushing the PDF files to gh-pages because this script was not triggered by Travis CI." 1>&2
    exit 1
else
    CURRENT_BRANCH=$(current_travis_branch)
    if [ "x_${CURRENT_BRANCH}" = "x_master" ]; then
        push_pdf_files_to_gh_pages
    else
        echo "Not pushing the PDF files to gh-pages because the current branch ${CURRENT_BRANCH} is not master branch."
    fi
fi
