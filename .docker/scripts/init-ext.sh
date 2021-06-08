#!/usr/bin/env sh
##
# Install current extension.
#
set -e

PIP="${APP_DIR}/bin/pip"
cd $WORKDIR
$PIP install -r "requirements.txt"
$PIP install -r "requirements-dev.txt"
EXTENSIONS_FILE=$WORKDIR/scripts/extensions.yml python $(dirname $0)/generate-ext-requirements.py
$PIP install --force-reinstall -r "/app/requirements-ext.txt"

