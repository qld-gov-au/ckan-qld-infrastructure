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
EXTENSIONS_FILE=$APP_DIR/scripts/extensions.yml python $(dirname $0)/generate-ext-requirements.py
pip install --force-reinstall -r "/tmp/requirements-ext.txt"
for req in `ls $VENV_DIR/src/ckanext-*/requirements.txt`; do
    pip install -r "$req"
done

if [ "$VENV_DIR" != "" ]; then
  deactivate
fi
