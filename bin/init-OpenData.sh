ckan_cli datastore set-permissions | psql "postgresql://datastore_write:pass@postgres-datastore/datastore_test" --set ON_ERROR_STOP=1

# Initialise validation tables
ckan_cli validation init-db

# Initialise the Comments database tables
ckan_cli comments initdb
ckan_cli comments updatedb
ckan_cli comments init_notifications_db

# Initialise the archiver database tables
ckan_cli archiver init

# Initialise the reporting database tables
ckan_cli report initdb

# Initialise the QA database tables
ckan_cli qa init

# Initialise the data request tables if applicable
if (ckan_cli datarequests --help); then
    # Click 7+ expects hyphenated action names,
    # older Click expects underscore.
    if (ckan_cli datarequests init-db --help); then
        ckan_cli datarequests init-db
        ckan_cli datarequests update-db
    else
        ckan_cli datarequests init_db
        ckan_cli datarequests update_db
    fi
fi

#Initialise the Harvester database tables
ckan_cli harvester initdb
