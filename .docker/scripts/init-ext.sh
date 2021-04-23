#!/usr/bin/env sh
##
# Install current extension.
#
set -e

. /app/ckan/default/bin/activate

pip install -r "/app/requirements.txt"
pip install -r "/app/requirements-dev.txt"
EXTENSIONS_FILE=/app/scripts/extensions.yml python $(dirname $0)/generate-ext-requirements.py
pip install --force-reinstall -r "/app/requirements-ext.txt"

deactivate
