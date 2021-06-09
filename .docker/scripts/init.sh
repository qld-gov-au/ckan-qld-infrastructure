#!/usr/bin/env sh
##
# Initialise CKAN instance.
#
set -e

CKAN_USER_NAME="${CKAN_USER_NAME:-admin}"
CKAN_DISPLAY_NAME="${CKAN_DISPLAY_NAME:-Administrator}"
CKAN_USER_PASSWORD="${CKAN_USER_PASSWORD:-Password123!}"
CKAN_USER_EMAIL="${CKAN_USER_EMAIL:-admin@localhost}"

. ${APP_DIR}/bin/activate

ckan_cli () {
    if (which ckan > /dev/null); then
        ckan -c ${CKAN_INI} "$@"
    else
        paster --plugin=ckan "$@" -c ${CKAN_INI}
    fi
}
ckan_cli db clean || exit 1
ckan_cli db init || exit 1
ckan_cli user add "${CKAN_USER_NAME}"\
 fullname="${CKAN_DISPLAY_NAME}"\
 email="${CKAN_USER_EMAIL}"\
 password="${CKAN_USER_PASSWORD}" || exit 1
ckan_cli sysadmin add "${CKAN_USER_NAME}" || exit 1

# Create some base test data
. $WORKDIR/scripts/create-test-data.sh
