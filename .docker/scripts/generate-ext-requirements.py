# encoding: utf-8
import os
import six
import yaml

target_environment = os.environ.get('ENV', 'DEV')
requirement_list = ''
extensions = yaml.safe_load(open('extensions.yml'))['extensions'][target_environment]
for key, value in six.iteritems(extensions):
    requirement_list += 'git+{}@{}#egg={}\n'.format(value['url'], value['version'], value['shortname'])

requirement_file = open('/app/requirements-ext.txt', 'w')
requirement_file.write(requirement_list)
requirement_file.close()
