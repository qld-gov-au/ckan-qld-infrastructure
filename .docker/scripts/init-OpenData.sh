# Initialise validation tables
PASTER_PLUGIN=ckanext-validation ckan_cli validation init-db

# Initialise the Comments database tables
PASTER_PLUGIN=ckanext-ytp-comments ckan_cli initdb
PASTER_PLUGIN=ckanext-ytp-comments ckan_cli updatedb
PASTER_PLUGIN=ckanext-ytp-comments ckan_cli init_notifications_db

# Initialise the archiver database tables
PASTER_PLUGIN=ckanext-archiver ckan_cli archiver init

# Initialise the reporting database tables
PASTER_PLUGIN=ckanext-report ckan_cli report initdb

# Initialise the QA database tables
PASTER_PLUGIN=ckanext-qa ckan_cli qa init

##
# BEGIN: Add sysadmin config values.
# This needs to be done before closing datarequests as they require the below config values
#
echo "Adding ckan.datarequests.closing_circumstances:"

curl -LsH "Authorization: ${API_KEY}" \
    --data '{"ckan.datarequests.closing_circumstances":
        "Released as open data|nominate_dataset\r\nOpen dataset already exists|nominate_dataset\r\nPartially released|nominate_dataset\r\nTo be released as open data at a later date|nominate_approximate_date\r\nData openly available elsewhere\r\nNot suitable for release as open data\r\nRequested data not available/cannot be compiled\r\nRequestor initiated closure"}' \
    ${CKAN_ACTION_URL}/config_option_update

echo "Creating config value for resource formats:"

curl -LsH "Authorization: ${API_KEY}" \
    --data '{"ckanext.data_qld.resource_formats": "CSV\r\nHTML\r\nJSON\r\nRDF\r\nTXT\r\nXLS"}' \
    ${CKAN_ACTION_URL}/config_option_update
