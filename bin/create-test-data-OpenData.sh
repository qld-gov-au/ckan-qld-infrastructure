#!/usr/bin/env sh
##
# Create example content specific to Open Data BDD tests.
#
set -e
set -x

. ${APP_DIR}/bin/activate

##
# BEGIN: Add sysadmin config values.
#
curl -LsH "Authorization: ${API_KEY}" \
    --data '{
        "ckan.comments.profanity_list": "",
        "ckan.datarequests.closing_circumstances": "Released as open data|nominate_dataset\r\nOpen dataset already exists|nominate_dataset\r\nPartially released|nominate_dataset\r\nTo be released as open data at a later date|nominate_approximate_date\r\nData openly available elsewhere\r\nNot suitable for release as open data\r\nRequested data not available/cannot be compiled\r\nRequestor initiated closure",
        "ckanext.data_qld.resource_formats": "CSV\r\nHTML\r\nJSON\r\nRDF\r\nTXT\r\nXLS"
    }' \
    ${CKAN_ACTION_URL}/config_option_update

##
# END.
#

# Create private test dataset with our standard fields
curl -LsH "Authorization: ${API_KEY}" \
    --data '{"name": "test-dataset", "owner_org": "'"${TEST_ORG_ID}"'", "private": true,
"update_frequency": "monthly", "author_email": "admin@localhost", "version": "1.0",
"license_id": "other-open", "data_driven_application": "NO", "security_classification": "PUBLIC",
"notes": "private test", "de_identified_data": "NO"}' \
    ${CKAN_ACTION_URL}/package_create

# Create public test dataset with our standard fields
curl -LsH "Authorization: ${API_KEY}" \
    --data '{"name": "public-test-dataset", "owner_org": "'"${TEST_ORG_ID}"'",
"update_frequency": "monthly", "author_email": "admin@example.com", "version": "1.0",
"license_id": "other-open", "data_driven_application": "NO", "security_classification": "PUBLIC",
"notes": "public test", "de_identified_data": "NO", "resources": [
    {"name": "test-resource", "description": "Test resource description",
     "url": "https://example.com", "format": "HTML", "size": 1024}
]}' \
    ${CKAN_ACTION_URL}/package_create

##
# BEGIN: Create a Data Request organisation with test users for admin, editor and member and default data requests
#
# Data Requests requires a specific organisation to exist in order to create DRs for Data.Qld
DR_ORG_NAME=open-data-administration-data-requests
DR_ORG_TITLE="Open Data Administration (data requests)"

echo "Creating test users for ${DR_ORG_TITLE} Organisation:"

add_user_if_needed dr_admin "Data Request Admin" dr_admin@localhost
add_user_if_needed dr_editor "Data Request Editor" dr_editor@localhost
add_user_if_needed dr_member "Data Request Member" dr_member@localhost

echo "Creating ${DR_ORG_TITLE} Organisation:"

DR_ORG=$( \
    curl -LsH "Authorization: ${API_KEY}" \
    --data '{"name": "'"${DR_ORG_NAME}"'", "title": "'"${DR_ORG_TITLE}"'"}' \
    ${CKAN_ACTION_URL}/organization_create
)

DR_ORG_ID=$(echo $DR_ORG | $PYTHON $APP_DIR/bin/extract-id.py)

echo "Assigning test users to ${DR_ORG_TITLE} Organisation:"

curl -LsH "Authorization: ${API_KEY}" \
    --data '{"id": "'"${DR_ORG_ID}"'", "object": "dr_admin", "object_type": "user", "capacity": "admin"}' \
    ${CKAN_ACTION_URL}/member_create

curl -LsH "Authorization: ${API_KEY}" \
    --data '{"id": "'"${DR_ORG_ID}"'", "object": "dr_editor", "object_type": "user", "capacity": "editor"}' \
    ${CKAN_ACTION_URL}/member_create

curl -LsH "Authorization: ${API_KEY}" \
    --data '{"id": "'"${DR_ORG_ID}"'", "object": "dr_member", "object_type": "user", "capacity": "member"}' \
    ${CKAN_ACTION_URL}/member_create

echo "Creating test dataset for data request organisation:"

curl -LsH "Authorization: ${API_KEY}" \
    --data '{"name": "data_request_dataset", "title": "Dataset for data requests", "owner_org": "'"${DR_ORG_ID}"'",
"update_frequency": "near-realtime", "author_email": "dr_admin@localhost", "version": "1.0", "license_id": "cc-by-4",
"data_driven_application": "NO", "security_classification": "PUBLIC", "notes": "test", "de_identified_data": "NO"}'\
    ${CKAN_ACTION_URL}/package_create

##
# END.
#

echo "Creating test Data Request:"

curl -LsH "Authorization: ${API_KEY}" \
    --data '{"title": "Test Request", "description": "This is an example", "organization_id": "'"${TEST_ORG_ID}"'"}' \
    ${CKAN_ACTION_URL}/create_datarequest

##
# BEGIN: Create a Reporting organisation with test users
#

REPORT_ORG_NAME=reporting-org
REPORT_ORG_TITLE="Reporting Organisation"

echo "Creating test users for ${REPORT_ORG_TITLE} Organisation:"

add_user_if_needed report_admin "Reporting Admin" report_admin@localhost
add_user_if_needed report_editor "Reporting Editor" report_editor@localhost

echo "Creating ${REPORT_ORG_TITLE} Organisation:"

REPORT_ORG=$( \
    curl -LsH "Authorization: ${API_KEY}" \
    --data '{"name": "'"${REPORT_ORG_NAME}"'", "title": "'"${REPORT_ORG_TITLE}"'"}' \
    ${CKAN_ACTION_URL}/organization_create
)

REPORT_ORG_ID=$(echo $REPORT_ORG | $PYTHON $APP_DIR/bin/extract-id.py)

echo "Assigning test users to ${REPORT_ORG_TITLE} Organisation:"

curl -LsH "Authorization: ${API_KEY}" \
    --data '{"id": "'"${REPORT_ORG_ID}"'", "object": "report_admin", "object_type": "user", "capacity": "admin"}' \
    ${CKAN_ACTION_URL}/member_create

curl -LsH "Authorization: ${API_KEY}" \
    --data '{"id": "'"${REPORT_ORG_ID}"'", "object": "report_editor", "object_type": "user", "capacity": "editor"}' \
    ${CKAN_ACTION_URL}/member_create

echo "Creating test dataset for reporting:"

curl -LsH "Authorization: ${API_KEY}" \
    --data '{"name": "reporting-dataset", "title": "Dataset for reporting", "owner_org": "'"${REPORT_ORG_ID}"'",
"update_frequency": "near-realtime", "author_email": "report_admin@localhost", "version": "1.0", "license_id": "cc-by-4",
"data_driven_application": "NO", "security_classification": "PUBLIC", "notes": "test", "de_identified_data": "NO"}'\
    ${CKAN_ACTION_URL}/package_create

echo "Creating test Data Request for reporting:"

curl -LsH "Authorization: ${API_KEY}" \
    --data '{"title": "Reporting Request", "description": "Data Request for reporting", "organization_id": "'"${REPORT_ORG_ID}"'"}' \
    ${CKAN_ACTION_URL}/create_datarequest

##
# END.
#

. ${APP_DIR}/bin/deactivate
