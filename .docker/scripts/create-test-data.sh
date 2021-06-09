
#!/usr/bin/env sh
##
# Create some example content for extension BDD tests.
#
set -e

CKAN_ACTION_URL=http://ckan:3000/api/action

. ${APP_DIR}/bin/activate

ckan_cli () {
    if (which ckan > /dev/null); then
        ckan -c ${CKAN_INI} "$@"
    else
        paster --plugin=ckan "$@" -c ${CKAN_INI}
    fi
}

# We know the "admin" sysadmin account exists, so we'll use her API KEY to create further data
API_KEY=$(ckan_cli user admin | tr -d '\n' | sed -r 's/^(.*)apikey=(\S*)(.*)/\2/')

# Creating test data hierarchy which creates organisations assigned to datasets
ckan_cli create-test-data hierarchy

# Creating basic test data which has datasets with resources
ckan_cli create-test-data

echo "Updating annakarenina to use department-of-health Organisation:"
package_owner_org_update=$( \
    curl -L -s --header "Authorization: ${API_KEY}" \
    --data "id=annakarenina&organization_id=department-of-health" \
    ${CKAN_ACTION_URL}/package_owner_org_update
)
echo ${package_owner_org_update}

deactivate
