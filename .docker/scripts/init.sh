#!/usr/bin/env sh
##
# Initialise CKAN data for testing.
#
set -e

if [ "$VENV_DIR" != "" ]; then
  . ${VENV_DIR}/bin/activate
fi
CLICK_ARGS="--yes" ckan_cli db clean
ckan_cli db init
ckan_cli db upgrade
ckan_cli datastore set-permissions | psql "postgresql://ckan:ckan@postgres-datastore/ckan?sslmode=disable" --set ON_ERROR_STOP=1
. $APP_DIR/scripts/init-${VARS_TYPE}.sh

# Create some base test data
. $APP_DIR/scripts/create-test-data.sh
. $APP_DIR/scripts/create-test-data-$VARS_TYPE.sh
