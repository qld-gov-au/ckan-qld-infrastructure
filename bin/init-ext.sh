#!/usr/bin/env sh
##
# Install current extension.
#
set -ex

install_requirements_file () {
    if [ "$TOOL" = "uv" ]; then
        uv pip install --system -r "$1"
    else
        pip install -r "$1"
    fi
}

install_requirements () {
    PROJECT_DIR=$1
    shift
    # Identify the best match requirements file, ignore the others.
    # If there is one specific to our CKAN or Python version, use that.
    for filename_pattern in "$@"; do
        filename="$PROJECT_DIR/${filename_pattern}-$CKAN_VERSION.txt"
        if [ -f "$filename" ]; then
            install_requirements_file "$filename"
            return 0
        fi
    done
    for filename_pattern in "$@"; do
        filename="$PROJECT_DIR/${filename_pattern}-$PYTHON_VERSION.txt"
        if [ -f "$filename" ]; then
            install_requirements_file "$filename"
            return 0
        fi
    done
    for filename_pattern in "$@"; do
        filename="$PROJECT_DIR/$filename_pattern.txt"
        if [ -f "$filename" ]; then
            install_requirements_file "$filename"
            return 0
        fi
    done
}

. "${APP_DIR}"/bin/activate
install_requirements . dev-requirements requirements-dev
EXTENSIONS_FILE=$APP_DIR/bin/extensions.yml $PYTHON $(dirname $0)/generate-ext-requirements.py
install_requirements_file "/tmp/requirements-ext.txt"
for extension in . `ls -d $SRC_DIR/ckanext-*`; do
    TOOL=uv install_requirements $extension requirements pip-requirements
done

install_requirements . dev-requirements requirements-dev

. "${APP_DIR}"/bin/process-config.sh
. "${APP_DIR}"/bin/deactivate
