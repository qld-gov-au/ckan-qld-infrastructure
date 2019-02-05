#!/bin/bash
#deploy CKAN base infrastructure

#ensure we die if any function fails
set -e

ansible-playbook -i inventory/hosts "vpc.yml" --extra-vars "Environment=$bamboo_deploy_environment" -vvv
ansible-playbook -i inventory/hosts "security_groups.yml" --extra-vars "Environment=$bamboo_deploy_environment" -vvv
ansible-playbook -i inventory/hosts "OpenData-database.yml" --extra-vars "Environment=$bamboo_deploy_environment" -vvv
ansible-playbook -i inventory/hosts "OpenData-efs.yml" --extra-vars "Environment=$bamboo_deploy_environment" -vvv
ansible-playbook -i inventory/hosts "OpenData-CKAN-Stack.yml" --extra-vars "Environment=$bamboo_deploy_environment" -vvv
