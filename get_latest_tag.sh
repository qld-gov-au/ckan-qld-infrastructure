#!/bin/sh

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <directory> [branch]" >&2
    exit 1
fi
GIT_DIR=../$1/.git
if ! [ -e "$GIT_DIR" ]; then
    GIT_DIR=$HOME/projects/$1/.git
fi
if ! [ -e "$GIT_DIR" ]; then
    echo "$GIT_DIR not found" >&2
    exit 1
fi

git --git-dir="$GIT_DIR" fetch >/dev/null
git --git-dir="$GIT_DIR" fetch --tags >/dev/null
git remote | grep upstream >/dev/null && git --git-dir="$GIT_DIR" fetch upstream --tags >/dev/null
TAG=$(git --git-dir="$GIT_DIR" tag -l --sort=committerdate | tail -1)
BRANCH="$2"
if [ "$BRANCH" = "" ]; then
    if (git --git-dir="$GIT_DIR" branch -r |grep origin/main) 2>&1 >/dev/null; then
        BRANCH=main
    elif (git --git-dir="$GIT_DIR" branch -r |grep origin/master) 2>&1 >/dev/null; then
        BRANCH=master
    fi
fi

if [ "$BRANCH" = "" ] || [ "$BRANCH" = "none" ]; then
    echo $TAG
else
    DIFF=$(git --git-dir="$GIT_DIR" diff --stat "$TAG" "origin/$BRANCH")
    if [ "$DIFF" = "" ]; then
        echo $TAG
    else
        echo $BRANCH
    fi
fi
