#!/usr/bin/env sh
##
# Install current extension.
#
set -e

. /app/ckan/default/bin/activate

pip install -r "/app/requirements.txt"
pip install -r "/app/requirements-dev.txt"
#python setup.py develop
python $(dirname $0)/generate-ext-requirements.py
pip install -r "/app/requirements-ext.txt"

# Validate that the extension was installed correctly.
#if ! pip list | grep ckan-qld-infrastructure > /dev/null; then echo "Unable to find the extension in the list"; exit 1; fi

deactivate
