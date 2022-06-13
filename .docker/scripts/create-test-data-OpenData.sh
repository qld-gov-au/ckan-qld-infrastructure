#!/usr/bin/env sh
##
# Create example content specific to Open Data BDD tests.
#
set -e
set -x

if [ "$VENV_DIR" != "" ]; then
  . ${VENV_DIR}/bin/activate
fi

# Create test dataset with our standard fields
curl -LsH "Authorization: ${API_KEY}" \
    --data '{"name": "test-dataset", "owner_org": "'"${TEST_ORG_ID}"'", "private": true,
"update_frequency": "monthly", "author_email": "admin@localhost", "version": "1.0",
"license_id": "other-open", "data_driven_application": "NO", "security_classification": "PUBLIC",
"notes": "test", "de_identified_data": "NO"}' \
    ${CKAN_ACTION_URL}/package_create

if [ "$VENV_DIR" != "" ]; then
  deactivate
fi
