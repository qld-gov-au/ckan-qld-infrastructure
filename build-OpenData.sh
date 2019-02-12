#!/bin/bash
#deploy CKAN base infrastructure

#ensure we die if any function fails
set -e

ANSIBLE_EXTRA_VARS="$ANSIBLE_EXTRA_VARS Environment=$bamboo_deploy_environment"

ansible-playbook -i inventory/hosts "vpc.yml" --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
ansible-playbook -i inventory/hosts "security_groups.yml" --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
ansible-playbook -i inventory/hosts "database.yml" --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
ansible-playbook -i inventory/hosts "efs.yml" --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
# ansible-playbook -i inventory/hosts "OpenData-database.yml" --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
ansible-playbook -i inventory/hosts "OpenData-CKAN-Stack.yml" --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
ansible-playbook -i inventory/hosts "OpenData-CKAN-instances.yml" --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
