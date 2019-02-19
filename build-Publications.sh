#!/bin/bash
#deploy CKAN base infrastructure


ANSIBLE_EXTRA_VARS="$ANSIBLE_EXTRA_VARS region=ap-southeast-2 Environment=$bamboo_deploy_environment titlecase_name=Publications lowercase_name=publications"

ansible-playbook -i inventory/hosts "vpc.yml" --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv

#ensure we die if any function fails after this
set -e

ansible-playbook -i inventory/hosts "security_groups.yml" --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
ansible-playbook -i inventory/hosts "database.yml" --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
ansible-playbook -i inventory/hosts "database-config.yml" --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
ansible-playbook -i inventory/hosts "efs.yml" --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
ansible-playbook -i inventory/hosts "cache.yml" --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
ansible-playbook -i inventory/hosts "CKAN-Stack.yml" --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
ansible-playbook -i inventory/hosts "CKAN-instances.yml" --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
