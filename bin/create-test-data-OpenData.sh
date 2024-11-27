#!/usr/bin/env sh
##
# Create example content specific to Open Data BDD tests.
#
set -ex

##
# BEGIN: Add sysadmin config values.
#
api_call '{
        "ckan.comments.profanity_list": "",
        "ckan.datarequests.closing_circumstances": "Released as open data|nominate_dataset\r\nOpen dataset already exists|nominate_dataset\r\nPartially released|nominate_dataset\r\nTo be released as open data at a later date|nominate_approximate_date\r\nData openly available elsewhere\r\nNot suitable for release as open data\r\nRequested data not available/cannot be compiled\r\nRequestor initiated closure",
        "ckanext.data_qld.resource_formats": "CSV\r\nHTML\r\nJSON\r\nRDF\r\nTXT\r\nXLS"
    }' config_option_update

##
# END.
#

# Create private test dataset with our standard fields
api_call '{"name": "test-dataset", "owner_org": "'"${TEST_ORG_ID}"'", "private": true,
"update_frequency": "monthly", "author_email": "admin@localhost", "version": "1.0",
"license_id": "other-open", "data_driven_application": "NO", "security_classification": "PUBLIC",
"notes": "private test", "de_identified_data": "NO"}' package_create

# Create public test dataset with our standard fields
api_call '{"name": "public-test-dataset", "owner_org": "'"${TEST_ORG_ID}"'",
"update_frequency": "monthly", "author_email": "admin@example.com", "version": "1.0",
"license_id": "other-open", "data_driven_application": "NO", "security_classification": "PUBLIC",
"notes": "public test", "de_identified_data": "NO", "resources": [
    {"name": "test-resource", "description": "Test resource description",
     "url": "https://example.com/foo", "format": "HTML", "size": 1024}
]}' package_create

# Populate Archiver data for test dataset
ckan_cli archiver update-test public-test-dataset

##
# BEGIN: Create a Data Request organisation with test users for admin, editor and member and default data requests
#
# Data Requests requires a specific organisation to exist in order to create DRs for Data.Qld
DR_ORG_NAME=open-data-administration-data-requests
DR_ORG_TITLE="Open Data Administration (data requests)"

echo "Creating test users for ${DR_ORG_TITLE} Organisation:"

add_user_if_needed dr_admin "Data Request Admin" dr_admin@localhost
add_user_if_needed dr_editor "Data Request Editor" dr_editor@localhost

echo "Creating ${DR_ORG_TITLE} Organisation:"

DR_ORG=$( \
    api_call '{"name": "'"${DR_ORG_NAME}"'", "title": "'"${DR_ORG_TITLE}"'"}' organization_create
)

DR_ORG_ID=$(echo $DR_ORG | $PYTHON $APP_DIR/bin/extract-id.py)

echo "Assigning test users to ${DR_ORG_TITLE} Organisation:"

api_call '{"id": "'"${DR_ORG_ID}"'", "object": "dr_admin", "object_type": "user", "capacity": "admin"}' member_create

api_call '{"id": "'"${DR_ORG_ID}"'", "object": "dr_editor", "object_type": "user", "capacity": "editor"}' member_create

echo "Creating test dataset for data request organisation:"

api_call '{"name": "data_request_dataset", "title": "Dataset for data requests", "owner_org": "'"${DR_ORG_ID}"'",
"update_frequency": "near-realtime", "author_email": "dr_admin@localhost", "version": "1.0", "license_id": "cc-by-4",
"data_driven_application": "NO", "security_classification": "PUBLIC", "notes": "test", "de_identified_data": "NO"}'package_create

echo "Creating test Data Request:"

api_call '{"title": "Test Request", "description": "This is an example", "organization_id": "'"${TEST_ORG_ID}"'"}' create_datarequest

##
# END.
#

##
# BEGIN: Create a Reporting organisation
#

REPORT_ORG_NAME=reporting-org
REPORT_ORG_TITLE="Reporting Organisation"

echo "Creating admin user for ${REPORT_ORG_TITLE} Organisation:"

add_user_if_needed report_admin "Reporting Admin" report_admin@localhost

echo "Creating ${REPORT_ORG_TITLE} Organisation:"

REPORT_ORG=$( \
    api_call '{"name": "'"${REPORT_ORG_NAME}"'", "title": "'"${REPORT_ORG_TITLE}"'"}' organization_create
)

REPORT_ORG_ID=$(echo $REPORT_ORG | $PYTHON $APP_DIR/bin/extract-id.py)

echo "Assigning admin user to ${REPORT_ORG_TITLE} Organisation:"

api_call '{"id": "'"${REPORT_ORG_ID}"'", "object": "report_admin", "object_type": "user", "capacity": "admin"}' member_create

echo "Creating test Data Request for reporting:"

api_call '{"title": "Reporting Request", "description": "Data Request for reporting", "organization_id": "'"${REPORT_ORG_ID}"'"}' create_datarequest

##
# END.
#

