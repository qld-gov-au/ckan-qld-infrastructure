#!/bin/bash
#deploy CKAN base infrastructure

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
  PARALLEL=1 ./opsworks-deploy.sh update_custom_cookbooks $STACK_NAME || exit 1
  ./opsworks-deploy.sh setup $STACK_NAME ${INSTANCE_SHORTNAME}-web || exit 1
  ./opsworks-deploy.sh execute_recipes $STACK_NAME ${INSTANCE_SHORTNAME}-solr datashades::solr-deploy || exit 1
  PARALLEL=1 ./opsworks-deploy.sh configure $STACK_NAME || exit 1
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

