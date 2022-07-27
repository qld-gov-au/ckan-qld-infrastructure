#!/usr/bin/env sh
##
# Install current extension.
#
set -e

install_requirements () {
    PROJECT_DIR="$1"
    for filename in requirements-$PYTHON_VERSION.txt requirements.txt pip-requirements.txt; do
        if [ -f "$PROJECT_DIR/$filename" ]; then
            pip install -r "$PROJECT_DIR/$filename"
            return 0
        fi
    done
}

install_dev_requirements () {
    PROJECT_DIR="$1"
    for filename in dev-requirements-$PYTHON_VERSION.txt requirements-dev-$PYTHON_VERSION.txt requirements-dev.txt dev-requirements.txt; do
        if [ -f "$PROJECT_DIR/$filename" ]; then
            pip install -r "$PROJECT_DIR/$filename"
            return 0
        fi
    done
}

if [ "$VENV_DIR" != "" ]; then
  . ${VENV_DIR}/bin/activate
fi
pip install -r "requirements.txt"
pip install -r "requirements-dev.txt"
EXTENSIONS_FILE=$APP_DIR/scripts/extensions.yml python $(dirname $0)/generate-ext-requirements.py
pip install --force-reinstall -r "/tmp/requirements-ext.txt"
for extension in . `ls -d $VENV_DIR/src/ckanext-*`; do
    install_requirements $extension
done

if [ "$VENV_DIR" != "" ]; then
  deactivate
fi
