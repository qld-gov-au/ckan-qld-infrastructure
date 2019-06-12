#!/bin/bash
#deploy Publications base infrastructure

run-all-playbooks () {
  #ensure we die if any function fails
  set -e

  run-shared-resource-playbooks
  run-playbook "database-config"
  run-playbook "CKAN-Stack"
  run-playbook "CKAN-extensions.yml"
  run-playbook CloudFormation "vars/CKAN-instances.yml"
  run-playbook "cloudfront"
  run-playbook "opsworks-deployment" "Deployment_Type=update_custom_cookbooks"
  run-playbook "opsworks-deployment" "vars/CKAN-deployment.var.yml"
  run-playbook "opsworks-deployment" "Deployment_Type=configure"
}

. ./build-CKAN.sh vars/Publications.yml $bamboo_deploy_environment $@
