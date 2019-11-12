#!/bin/bash
#deploy Publications base infrastructure

INSTANCE_NAME=Publications
INSTANCE_SHORTNAME=`echo $INSTANCE_NAME |tr '[A-Z]' '[a-z]'`
STACK_NAME="${INSTANCE_NAME}_$bamboo_deploy_environment"

run-deployment () {
  PARALLEL=1 ./opsworks-deploy.sh update_custom_cookbooks $STACK_NAME
  ./opsworks-deploy.sh setup $STACK_NAME ${INSTANCE_SHORTNAME}-web
  ./opsworks-deploy.sh execute_recipes $STACK_NAME ${INSTANCE_SHORTNAME}-solr datashades::solr-deploy
  PARALLEL=1 ./opsworks-deploy.sh configure $STACK_NAME
}

run-all-playbooks () {
  #ensure we die if any function fails
  set -e

  run-shared-resource-playbooks
  run-playbook "CloudFormation" "vars/acm.var.yml"
  run-playbook "database-config"
  run-playbook "CloudFormation" "vars/s3_buckets.var.yml"
  run-playbook "CKAN-Stack"
  run-playbook "CKAN-extensions" "vars/CKAN-extensions.var.yml"
  run-playbook "CloudFormation" "vars/CKAN-instances.var.yml"
  run-playbook "CloudFormation" "vars/cloudfront-lambda-at-edge.var.yml"
  run-playbook "cloudfront"
  run-deployment
}

. ./build-CKAN.sh vars/shared-$INSTANCE_NAME.var.yml $bamboo_deploy_environment $@
