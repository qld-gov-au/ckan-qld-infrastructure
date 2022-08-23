#!/usr/bin/env sh
##
# Initialise CKAN data for testing.
#
set -e

. ${APP_DIR}/scripts/activate
CLICK_ARGS="--yes" ckan_cli db clean
ckan_cli db init
ckan_cli db upgrade
. $APP_DIR/scripts/init-${VARS_TYPE}.sh

# Create some base test data
. $APP_DIR/scripts/create-test-data.sh
. $APP_DIR/scripts/create-test-data-$VARS_TYPE.sh
