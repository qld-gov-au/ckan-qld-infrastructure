#!/usr/bin/env sh
##
# Create some example content for extension BDD tests.
#
set -e

CKAN_ACTION_URL=http://ckan:3000/api/action

if [ "$VENV_DIR" != "" ]; then
  . ${VENV_DIR}/bin/activate
fi

add_user_if_needed () {
    echo "Adding user '$2' ($1) with email address [$3]"
    ckan_cli user "$1" | grep "$1" || ckan_cli user add "$1"\
        fullname="$2"\
        email="$3"\
        password="${4:-Password123!}"
}

# We know the "admin" sysadmin account exists, so we'll use her API KEY to create further data
API_KEY=$(ckan_cli user admin | tr -d '\n' | sed -r 's/^(.*)apikey=(\S*)(.*)/\2/')

##
# BEGIN: Create a test organisation with test users for admin, editor and member
#
TEST_ORG_NAME=test-organisation
TEST_ORG_TITLE="Test Organisation"

echo "Creating test users for ${TEST_ORG_TITLE} Organisation:"

add_user_if_needed ckan_user "CKAN User" ckan_user@localhost
add_user_if_needed test_org_admin "Test Admin" test_org_admin@localhost
add_user_if_needed test_org_editor "Test Editor" test_org_editor@localhost
add_user_if_needed test_org_member "Test Member" test_org_member@localhost

echo "Creating ${TEST_ORG_TITLE} Organisation:"

TEST_ORG=$( \
    curl -LsH "Authorization: ${API_KEY}" \
    --data "name=${TEST_ORG_NAME}&title=${TEST_ORG_TITLE}" \
    ${CKAN_ACTION_URL}/organization_create
)

TEST_ORG_ID=$(echo $TEST_ORG | sed -r 's/^(.*)"id": "(.*)",(.*)/\2/')

echo "Assigning test users to ${TEST_ORG_TITLE} Organisation:"

curl -LsH "Authorization: ${API_KEY}" \
    --data "id=${TEST_ORG_ID}&object=test_org_admin&object_type=user&capacity=admin" \
    ${CKAN_ACTION_URL}/member_create

curl -LsH "Authorization: ${API_KEY}" \
    --data "id=${TEST_ORG_ID}&object=test_org_editor&object_type=user&capacity=editor" \
    ${CKAN_ACTION_URL}/member_create

curl -LsH "Authorization: ${API_KEY}" \
    --data "id=${TEST_ORG_ID}&object=test_org_member&object_type=user&capacity=member" \
    ${CKAN_ACTION_URL}/member_create
##
# END.
#

# Creating test data hierarchy which creates organisations assigned to datasets
ckan_cli create-test-data hierarchy

# Creating basic test data which has datasets with resources
ckan_cli create-test-data

# Datasets need to be assigned to an organisation

echo "Assigning test Datasets to Organisation..."

echo "Updating annakarenina to use ${TEST_ORG_TITLE} organisation:"
package_owner_org_update=$( \
    curl -LsH "Authorization: ${API_KEY}" \
    --data "id=annakarenina&organization_id=${TEST_ORG_NAME}" \
    ${CKAN_ACTION_URL}/package_owner_org_update
)
echo ${package_owner_org_update}

echo "Updating warandpeace to use ${TEST_ORG_TITLE} organisation:"
package_owner_org_update=$( \
    curl -LsH "Authorization: ${API_KEY}" \
    --data "id=warandpeace&organization_id=${TEST_ORG_NAME}" \
    ${CKAN_ACTION_URL}/package_owner_org_update
)
echo ${package_owner_org_update}

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
    --data "name=${DR_ORG_NAME}&title=${DR_ORG_TITLE}" \
    ${CKAN_ACTION_URL}/organization_create
)

DR_ORG_ID=$(echo $DR_ORG | sed -r 's/^(.*)"id": "(.*)",(.*)/\2/')

echo "Assigning test users to ${DR_ORG_TITLE} Organisation:"

curl -LsH "Authorization: ${API_KEY}" \
    --data "id=${DR_ORG_ID}&object=dr_admin&object_type=user&capacity=admin" \
    ${CKAN_ACTION_URL}/member_create

curl -LsH "Authorization: ${API_KEY}" \
    --data "id=${DR_ORG_ID}&object=dr_editor&object_type=user&capacity=editor" \
    ${CKAN_ACTION_URL}/member_create

curl -LsH "Authorization: ${API_KEY}" \
    --data "id=${DR_ORG_ID}&object=dr_member&object_type=user&capacity=member" \
    ${CKAN_ACTION_URL}/member_create


echo "Creating test Data Request:"

curl -LsH "Authorization: ${API_KEY}" \
    --data "title=Test Request&description=This is an example&organization_id=${TEST_ORG_ID}" \
    ${CKAN_ACTION_URL}/create_datarequest

REPORT_ORG_NAME=reporting
REPORT_ORG_TITLE=Reporting

echo "Creating test users for ${REPORT_ORG_TITLE} Organisation:"

add_user_if_needed report_admin "Reporting Admin" report_admin@localhost
add_user_if_needed report_editor "Reporting Editor" report_editor@localhost

echo "Creating ${REPORT_ORG_TITLE} Organisation:"

REPORT_ORG=$( \
    curl -LsH "Authorization: ${API_KEY}" \
    --data "name=${REPORT_ORG_NAME}&title=${REPORT_ORG_TITLE}" \
    ${CKAN_ACTION_URL}/organization_create
)

REPORT_ORG_ID=$(echo $REPORT_ORG | sed -r 's/^(.*)"id": "(.*)",(.*)/\2/')

echo "Assigning test users to ${REPORT_ORG_TITLE} Organisation:"

curl -LsH "Authorization: ${API_KEY}" \
    --data "id=${REPORT_ORG_ID}&object=report_admin&object_type=user&capacity=admin" \
    ${CKAN_ACTION_URL}/member_create

curl -LsH "Authorization: ${API_KEY}" \
    --data "id=${REPORT_ORG_ID}&object=report_editor&object_type=user&capacity=editor" \
    ${CKAN_ACTION_URL}/member_create

echo "Creating test dataset for reporting:"

curl -LsH "Authorization: ${API_KEY}" \
    --data "name=reporting&description=Dataset for reporting&owner_org=${REPORT_ORG_ID}&\
update_frequency=near-realtime&author_email=report_admin@localhost&version=1.0&license_id=cc-by-4\
&data_driven_application=NO&security_classification=PUBLIC&notes=test&de_identified_data=NO"\
    ${CKAN_ACTION_URL}/package_create

echo "Creating test Data Request for reporting:"

curl -LsH "Authorization: ${API_KEY}" \
    --data "title=Reporting Request&description=Data Request for reporting&organization_id=${REPORT_ORG_ID}" \
    ${CKAN_ACTION_URL}/create_datarequest


echo "Creating config value for resource formats:"

curl -LsH "Authorization: ${API_KEY}" \
    --data '{"ckanext.data_qld.resource_formats": "CSV\r\nHTML\r\nJSON\r\nRDF\r\nTXT\r\nXLS"}' \
    ${CKAN_ACTION_URL}/config_option_update

if [ "$VENV_DIR" != "" ]; then
  deactivate
fi
