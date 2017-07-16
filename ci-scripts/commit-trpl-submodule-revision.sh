#!/usr/bin/env bash

# This script commits trpl submodule's revision if it has been chaned, and
# pushes the commit to the remote repository.
#
# Requires: `bash` -- because `local` and `pipefail` are used.

set -u -e -o pipefail

source ./ci-scripts/common-lib

TRPL_DIR=the-rust-programming-language-ja

function commit_and_push_trpl_submodule_revision() {
    local current_branch
    current_branch=$(current_travis_branch)

    # Get the revision of trpl submodule.
    local revision
    revision=$(cd ${TRPL_DIR}; git rev-parse --short HEAD)

    git checkout ${current_branch}
    git add ${TRPL_DIR}
    set +e
    ret=$(git status | grep -q 'Changes to be committed:'; echo $?)
    set -e

    if [ $ret -eq 0 ] ; then
        echo "Committing trpl submodule's new revision ${revision}."
        local commit_message;
        commit_message=$(cat <<EOF
auto commit on travis ${TRAVIS_JOB_NUMBER} [ci skip]

Update ${TRPL_DIR} submodule to ${revision}.
EOF
)
        git commit -m "${commit_message}"
        local remote_url
        remote_url=$(get_remote_ssh_repo_url)
        echo "Pushing to ${current_branch} branch of ${remote_url}."
        git push ${remote_url} ${current_branch}:${current_branch}
    else
        echo "There is no change in trpl submodule. (revision: ${revision})"
    fi
}

exit_if_not_ci
commit_and_push_trpl_submodule_revision
