#!/usr/bin/env bash
##
# Build site in CI.
#
set -ex

# Process Docker Compose configuration. This is used to avoid multiple
# docker-compose.yml files.
# Remove lines containing '###'.
sed -i -e "/###/d" docker-compose.yml
# Uncomment lines containing '##'.
sed -i -e "s/##//" docker-compose.yml

# Pull the latest images.
ahoy pull

PYTHON=python3
CKAN_GIT_VERSION=`sh ./retrieve-ckan-version.sh`
CKAN_VERSION=$(echo $CKAN_GIT_VERSION |grep -Eo '[0-9]+[.][0-9]*')
export CKAN_VERSION

sed "s|{CKAN_VERSION}|$CKAN_VERSION|g" .docker/Dockerfile-template.ckan \
    | sed "s|{CKAN_GIT_VERSION}|$CKAN_GIT_VERSION|g" \
    | sed "s|{PYTHON_VERSION}|$PYTHON_VERSION|g" \
    | sed "s|{DEPLOY_ENV}|$DEPLOY_ENV|g" \
    | sed "s|{VARS_TYPE}|$VARS_TYPE|g" \
    | sed "s|{PYTHON}|$PYTHON|g" \
    > .docker/Dockerfile.ckan

ahoy build
