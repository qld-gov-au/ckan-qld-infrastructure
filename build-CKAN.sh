#!/bin/bash
#deploy CKAN base infrastructure

#ensure we die if any function fails
set -e

VARS_FILE="$1"
ENVIRONMENT="$2"
ANSIBLE_EXTRA_VARS="$ANSIBLE_EXTRA_VARS Environment=$ENVIRONMENT"

set -x

run-playbook () {
  if [ -z "$2" ]; then
    unset VARS_FILE_2
  elif [ -e "$2" ]; then
    VARS_FILE_2="--extra-vars @$2"
  else
    VARS_FILE_2="--extra-vars $2"
  fi
  PLAYBOOK="$1"
  if [ ! -e "$PLAYBOOK" ]; then
    PLAYBOOK="$PLAYBOOK.yml"
  fi
  ansible-playbook -i inventory/hosts "$PLAYBOOK" --extra-vars "@$VARS_FILE" $VARS_FILE_2 --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
}

run-shared-resource-playbooks () {
  run-playbook "vpc"
  run-playbook "security_groups"
  run-playbook "CloudFormation" "vars/hosted-zone.var.yml"
  run-playbook "CloudFormation" "vars/database.var.yml"
  run-playbook "CloudFormation" "vars/efs.var.yml"
  run-playbook "CloudFormation" "vars/cache.var.yml"
  run-playbook "CloudFormation" "vars/waf_web_acl.var.yml"
}

run-deployment () {
  PARALLEL=1 ./opsworks-deploy.sh update_custom_cookbooks $STACK_NAME
  ./opsworks-deploy.sh setup $STACK_NAME ${INSTANCE_SHORTNAME}-web & WEB_PID=$!
  PARALLEL=1 ./opsworks-deploy.sh setup $STACK_NAME ${INSTANCE_SHORTNAME}-batch & BATCH_PID=$!
  wait $WEB_PID
  wait $BATCH_PID
  STOPPED_INSTANCES=$(./opsworks-deploy.sh get_stopped_instances $STACK_NAME ${INSTANCE_SHORTNAME}-solr)
  if [ "$STOPPED_INSTANCES" = "" ]; then
    ./opsworks-deploy.sh execute_recipes $STACK_NAME ${INSTANCE_SHORTNAME}-solr datashades::solr-deploy || exit 1
  else
    ./opsworks-deploy.sh start $STACK_NAME ${INSTANCE_SHORTNAME}-solr
    ./opsworks-deploy.sh setup $STACK_NAME ${INSTANCE_SHORTNAME}-solr
    ./opsworks-deploy.sh stop $STACK_NAME ${INSTANCE_SHORTNAME}-solr "$STOPPED_INSTANCES"
  fi
  PARALLEL=1 ./opsworks-deploy.sh configure $STACK_NAME
}

run-all-playbooks () {
  run-shared-resource-playbooks
  run-playbook "CloudFormation" "vars/acm.var.yml"
  if [ "$SKIP_CKAN_DB" != "true" ]; then
    run-playbook "database-config"
  fi
  run-playbook "CloudFormation" "vars/s3_buckets.var.yml"
  run-playbook "CKAN-Stack"
  run-playbook "CKAN-extensions"
  run-playbook "CloudFormation" "vars/instances-${INSTANCE_NAME}.var.yml"
  run-playbook "CloudFormation" "vars/cloudfront-lambda-at-edge.var.yml"
  run-playbook "cloudfront"
  run-deployment
}

if [ $# -ge 3 ]; then
  if [ "$3" = "deploy" ]; then
    run-deployment
  elif [ "$3" = "setup" ]; then
    PARALLEL=1 ./opsworks-deploy.sh setup $STACK_NAME
  elif [ "$3" = "configure" ]; then
    PARALLEL=1 ./opsworks-deploy.sh update_custom_cookbooks $STACK_NAME
    PARALLEL=1 ./opsworks-deploy.sh configure $STACK_NAME
  else
    # run custom playbook
    run-playbook "$3" "$4"
  fi
else
  run-all-playbooks
fi

