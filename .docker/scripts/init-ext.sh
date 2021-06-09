#!/usr/bin/env sh
##
# Install current extension.
#
set -e

PIP="${APP_DIR}/bin/pip"
cd $WORKDIR
$PIP install -r "requirements.txt"
$PIP install -r "requirements-dev.txt"
EXTENSIONS_FILE=$WORKDIR/scripts/extensions.yml $APP_DIR/bin/python $(dirname $0)/generate-ext-requirements.py
$PIP install --force-reinstall -r "/tmp/requirements-ext.txt"

