# encoding: utf-8
import os
import six
import yaml

extensions_file = os.environ.get('EXTENSIONS_FILE', 'extensions.yml')
target_environment = os.environ.get('DEPLOY_ENV', 'DEV')
requirement_list = ''
extensions = yaml.safe_load(open(extensions_file))['extensions'][target_environment]
for key, value in six.iteritems(extensions):
    requirement_list += '-e git+{}@{}#egg={}\n'.format(value['url'], value['version'], value['shortname'])

requirement_file = open('/app/requirements-ext.txt', 'w')
requirement_file.write(requirement_list)
requirement_file.close()
