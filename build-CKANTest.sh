#!/bin/bash
#deploy CKAN Test base infrastructure

if [ "$bamboo_deploy_environment" = "" ]; then
  echo "Missing bamboo_deploy_environment" >&2
  exit 1
fi
INSTANCE_NAME=CKANTest
INSTANCE_SHORTNAME=`echo $INSTANCE_NAME |tr '[A-Z]' '[a-z]'`
STACK_NAME="${INSTANCE_NAME}_$bamboo_deploy_environment"

. ./build-CKAN.sh vars/shared-$INSTANCE_NAME.var.yml $bamboo_deploy_environment $@
