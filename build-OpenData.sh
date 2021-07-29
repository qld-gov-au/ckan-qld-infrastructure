#!/bin/bash
#deploy Open Data base infrastructure

if [ "$bamboo_deploy_environment" = "" ]; then
  echo "Missing bamboo_deploy_environment" >&2
  exit 1
fi
INSTANCE_NAME=OpenData
INSTANCE_SHORTNAME=`echo $INSTANCE_NAME |tr '[A-Z]' '[a-z]'`
STACK_NAME="${INSTANCE_NAME}_$bamboo_deploy_environment"

run-all-playbooks () {
  #ensure we die if any function fails
  set -e

  run-shared-resource-playbooks
  run-playbook "CloudFormation" "vars/acm.var.yml"
  if [ "$SKIP_CKAN_DB" != "true" ]; then
    run-playbook "database-config"
  fi
  run-playbook "CloudFormation" "vars/s3_buckets.var.yml"
  run-playbook "CKAN-Stack"
  run-playbook "CKAN-extensions"
  run-playbook "CloudFormation" "vars/${INSTANCE_NAME}-instances.var.yml"
  run-playbook "CloudFormation" "vars/cloudfront-lambda-at-edge.var.yml"
  run-playbook "cloudfront"
  run-deployment
}

. ./build-CKAN.sh vars/shared-$INSTANCE_NAME.var.yml $bamboo_deploy_environment $@
