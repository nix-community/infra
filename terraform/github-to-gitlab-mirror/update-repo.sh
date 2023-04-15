#!/usr/bin/env bash

set -euxo pipefail

if [ "${REPO:-}" = "" ]; then
    echo "REPO must be set"
    exit 1
fi

tempdir=$(mktemp -d)
cleanup() { rm -rf "$tempdir"; }
trap cleanup EXIT
cd "$tempdir"

git clone --bare "https://github.com/$REPO" .
git push --force --mirror "https://gitlab.com/$REPO"
