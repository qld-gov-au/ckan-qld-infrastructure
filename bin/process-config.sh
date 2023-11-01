if [ -d "$SRC_DIR/ckan/ckanext/activity" ]; then
    sed -i 's|^ckan.plugins =|ckan.plugins = activity|' $CKAN_INI .docker/test*.ini
fi

