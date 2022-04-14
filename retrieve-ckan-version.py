# encoding: utf-8
import os
import yaml

target_environment = os.environ.get('DEPLOY_ENV', 'DEV')

extensions_file = os.environ.get('EXTENSIONS_FILE', None)
if not extensions_file:
    vars_type = os.environ.get('VARS_TYPE')
    extensions_file = 'vars/shared-{}.var.yml'.format(vars_type)
facts = yaml.safe_load(open(extensions_file))['basic_facts']
for environment_facts in facts:
    if environment_facts['Environment'] == target_environment:
        if 'CKANRevision' in environment_facts:
            print(environment_facts['CKANRevision'])
        break
