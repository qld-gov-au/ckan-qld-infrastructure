#!/usr/bin/env sh
##
# Create example content specific to Publications BDD tests.
#
set -e
set -x

. ${APP_DIR}/bin/activate

# Create publishing standards dataset
curl -LsH "Authorization: ${API_KEY}" \
    --data '{"name": "publishing-standards-publications-qld-gov-au", "owner_org": "'"${TEST_ORG_ID}"'"}' \
    ${CKAN_ACTION_URL}/package_create

# Create private test dataset with our standard fields
curl -LsH "Authorization: ${API_KEY}" \
    --data '{"name": "test-dataset", "owner_org": "'"${TEST_ORG_ID}"'", "private": true,
"notes": "private test"}' \
    ${CKAN_ACTION_URL}/package_create

# Create public test dataset with our standard fields
curl -LsH "Authorization: ${API_KEY}" \
    --data '{"name": "public-test-dataset", "owner_org": "'"${TEST_ORG_ID}"'",
"notes": "public test", "resources": [
    {"name": "test-resource", "description": "Test resource description",
     "url": "https://example.com", "format": "HTML", "size": 1024}
]}' \
    ${CKAN_ACTION_URL}/package_create


. ${APP_DIR}/bin/deactivate
