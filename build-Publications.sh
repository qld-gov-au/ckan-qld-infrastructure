#!/bin/bash
#deploy Publications base infrastructure

run-all-playbooks () {
  #ensure we die if any function fails
  set -e

  run-shared-resource-playbooks
  run-playbook "CloudFormation" "vars/acm.var.yml"
  run-playbook "database-config"
  run-playbook "CKAN-Stack"
  run-playbook "CKAN-extensions" "vars/CKAN-extensions.var.yml"
  run-playbook "CloudFormation" "vars/CKAN-instances.var.yml"
  run-playbook "CloudFormation" "vars/cloudfront-lambda-at-edge.var.yml"
  run-playbook "cloudfront"
  run-playbook "opsworks-deployment" "Deployment_Type=update_custom_cookbooks"
  run-playbook "opsworks-deployment" "vars/CKAN-deployment.var.yml"
  run-playbook "opsworks-deployment" "Deployment_Type=configure"
}

. ./build-CKAN.sh vars/shared-Publications.var.yml $bamboo_deploy_environment $@
