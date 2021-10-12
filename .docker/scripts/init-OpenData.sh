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
