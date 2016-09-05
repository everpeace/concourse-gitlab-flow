#!/bin/bash

# repo-target: merge target
# repo: current branch
# out: output for push

git config --global user.email "${GIT_EMAIL}"
git config --global user.name "${GIT_NAME}"

cd repo-target
TARGET_BRANCH=$(git branch --contains | grep -v '('| sed 's/^\**[[:blank:]]*//g'| head -n 1)
echo "merge target branch:${TARGET_BRANCH}"
cd ..

cd out
shopt -s dotglob
rm -rf *
mv -f ../repo/* ./
GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git remote add -f repo-target ../repo-target

CURRENT_BRANCH=$(git branch --contains | grep -v '('| sed 's/^\**[[:blank:]]*//g'| head -n 1)
echo "current branch:${CURRENT_BRANCH}"

MESSAGE="${MESSAGE:-[Concourse CI] Merge branch ${TARGET_BRANCH} into ${CURRENT_BRANCH}}"

if [ "${CI_SKIP}" = "true" ]; then
  MESSAGE="[ci skip]${MESSAGE}"
fi

if [ "${NO_FF}" = "true" ]; then
  MERGE_MODE="--no-ff"
else
  MERGE_MODE="--ff"
fi

echo "MESSAGE=${MESSAGE}"
echo "MERGE_MODE=${MERGE_MODE}"
git merge ${MERGE_MODE} "repo-target/${TARGET_BRANCH}" -m "${MESSAGE}"
