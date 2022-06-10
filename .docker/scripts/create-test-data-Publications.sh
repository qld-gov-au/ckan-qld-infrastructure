#!/usr/bin/env sh
##
# Create example content specific to Publications BDD tests.
#
set -e
set -x

if [ "$VENV_DIR" != "" ]; then
  . ${VENV_DIR}/bin/activate
fi

# Create publishing standards dataset
curl -LsH "Authorization: ${API_KEY}" \
    --data '{"name": "publishing-standards-publications-qld-gov-au", "owner_org": "'"${TEST_ORG_ID}"'"}' \
    ${CKAN_ACTION_URL}/package_create

# Create test dataset with our standard fields
curl -LsH "Authorization: ${API_KEY}" \
    --data '{"name": "test-dataset", "owner_org": "'"${TEST_ORG_ID}"'", "is_private": true}' \
    ${CKAN_ACTION_URL}/package_create

if [ "$VENV_DIR" != "" ]; then
  deactivate
fi
