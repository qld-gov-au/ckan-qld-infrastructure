# encoding: utf-8

import os
import re
import six
import yaml


def check_version(current_version, repo_name):
    latest_tag = os.popen("./get_latest_tag.sh " + repo_name, 'r').readline().strip()
    if latest_tag and latest_tag != current_version:
        print("{}: {} is using version [{}] but [{}] is available".format(
            app, repo_name, current_version, latest_tag
        ))


target_environment = os.environ.get('DEPLOY_ENV', 'STAGING')
for app in ['OpenData', 'Publications', 'CKANTest']:
    extensions_file = os.environ.get('EXTENSIONS_FILE', 'vars/shared-{}.var.yml'.format(app))
    extensions = yaml.safe_load(open(extensions_file))['extensions'][target_environment]
    for key, value in six.iteritems(extensions):
        check_version(value['version'], value['shortname'])

template_parameters = yaml.safe_load(open('vars/CKAN-Stack.var.yml'))[
    'cloudformation_stacks'][0]['template_parameters']
match = re.search("[^']'([-a-z0-9.]+)'[^']", template_parameters['CookbookRevision'])
if match:
    check_version(match.group(1), 'ckan_cookbook')
else:
    print("Unable to locate cookbook version in " + template_parameters['CookbookRevision'])
