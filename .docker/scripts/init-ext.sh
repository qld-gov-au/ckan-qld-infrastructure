#!/usr/bin/env sh
##
# Install current extension.
#
set -e

if [ "$VENV_DIR" != "" ]; then
  . ${VENV_DIR}/bin/activate
fi
pip install -r "requirements.txt"
pip install -r "requirements-dev.txt"
EXTENSIONS_FILE=$APP_DIR/scripts/extensions.yml $APP_DIR/bin/python $(dirname $0)/generate-ext-requirements.py
pip install --force-reinstall -r "/tmp/requirements-ext.txt"

if [ "$VENV_DIR" != "" ]; then
  deactivate
fi
