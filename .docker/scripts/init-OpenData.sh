ckan_cli datastore set-permissions | psql "postgresql://ckan:ckan@postgres-datastore/ckan?sslmode=disable" --set ON_ERROR_STOP=1

# Initialise validation tables
PASTER_PLUGIN=ckanext-validation ckan_cli validation init-db

# Initialise the Comments database tables
PASTER_PLUGIN=ckanext-ytp-comments ckan_cli comments initdb
PASTER_PLUGIN=ckanext-ytp-comments ckan_cli comments updatedb
PASTER_PLUGIN=ckanext-ytp-comments ckan_cli comments init_notifications_db

# Initialise the archiver database tables
PASTER_PLUGIN=ckanext-archiver ckan_cli archiver init

# Initialise the reporting database tables
PASTER_PLUGIN=ckanext-report ckan_cli report initdb

# Initialise the QA database tables
PASTER_PLUGIN=ckanext-qa ckan_cli qa init

#Initiialise the Harvester database tables
PASTER_PLUGIN=ckanext-harvest ckan_cli harvester initdb
