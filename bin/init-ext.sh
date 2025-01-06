#!/usr/bin/env sh
##
# Install current extension.
#
set -ex

install_requirements () {
    PROJECT_DIR=$1
    shift
    # Identify the best match requirements file, ignore the others.
    # If there is one specific to our CKAN or Python version, use that.
    for filename_pattern in "$@"; do
        filename="$PROJECT_DIR/${filename_pattern}-$CKAN_VERSION.txt"
        if [ -f "$filename" ]; then
            pip install -r "$filename"
            return 0
        fi
    done
    for filename_pattern in "$@"; do
        filename="$PROJECT_DIR/${filename_pattern}-$PYTHON_VERSION.txt"
        if [ -f "$filename" ]; then
            pip install -r "$filename"
            return 0
        fi
    done
    for filename_pattern in "$@"; do
        filename="$PROJECT_DIR/$filename_pattern.txt"
        if [ -f "$filename" ]; then
            pip install -r "$filename"
            return 0
        fi
    done
}

. "${APP_DIR}"/bin/activate
install_requirements . dev-requirements requirements-dev
EXTENSIONS_FILE=$APP_DIR/bin/extensions.yml $PYTHON $(dirname $0)/generate-ext-requirements.py
pip install -r "/tmp/requirements-ext.txt"
for extension in . `ls -d $SRC_DIR/ckanext-*`; do
    install_requirements $extension requirements pip-requirements
done
if [ "$CKAN_VERSION" = "2.9" ]; then
  echo "CKAN 2.9 last supported Jinja2 is less than 3.1"
  pip install "jinja2<3.1"
fi

# force version that declares itself to be incompatible but actually works
pip install click==8.1.7
install_requirements . dev-requirements requirements-dev

. "${APP_DIR}"/bin/process-config.sh
. "${APP_DIR}"/bin/deactivate
