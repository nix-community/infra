#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Usage: $0 github_repo"
  exit 1
fi
github_repo=$1
last_commit=$(git ls-remote "https://github.com/$github_repo" HEAD | awk '{ print $1}')
# echo as json
echo "{\"last_commit\": \"$last_commit\"}"
