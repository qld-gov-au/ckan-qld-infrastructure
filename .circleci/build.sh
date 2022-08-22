#!/usr/bin/env bash
##
# Build site in CI.
#
set -e

# Process Docker Compose configuration. This is used to avoid multiple
# docker-compose.yml files.
# Remove lines containing '###'.
sed -i -e "/###/d" docker-compose.yml
# Uncomment lines containing '##'.
sed -i -e "s/##//" docker-compose.yml

# Pull the latest images.
ahoy pull

QGOV_CKAN_VERSION=`sh ./retrieve-ckan-version.sh`
CKAN_VERSION=2.9
PYTHON=python
if [ "$PYTHON_VERSION" = "py2" ]; then
    CKAN_VERSION="${CKAN_VERSION}-py2"
else
    PYTHON="${PYTHON}3"
fi
export CKAN_VERSION

sed "s|{CKAN_VERSION}|$CKAN_VERSION|g" .docker/Dockerfile-template.ckan \
    | sed "s|{PYTHON_VERSION}|$PYTHON_VERSION|g" \
    | sed "s|{DEPLOY_ENV}|$DEPLOY_ENV|g" \
    | sed "s|{VARS_TYPE}|$VARS_TYPE|g" \
    | sed "s|{PYTHON}|$PYTHON|g" \
    | sed "s|{QGOV_CKAN_VERSION}|$QGOV_CKAN_VERSION|g" > .docker/Dockerfile.ckan

ahoy build || (ahoy logs; exit 1)
