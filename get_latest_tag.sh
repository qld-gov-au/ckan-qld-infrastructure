#!/bin/sh

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <directory>" >&2
    exit 1
fi
GIT_DIR=../$1/.git
if ! [ -e "$GIT_DIR" ]; then
    echo "$GIT_DIR not found" >&2
    exit 1
fi

git --git-dir="$GIT_DIR" fetch --tags >/dev/null
git --git-dir="$GIT_DIR" tag -l --sort=committerdate | tail -1
