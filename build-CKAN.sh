#!/bin/bash
#deploy CKAN base infrastructure

VARS_FILE="$1"
ENVIRONMENT="$2"
ANSIBLE_EXTRA_VARS="$ANSIBLE_EXTRA_VARS Environment=$ENVIRONMENT"

set -x

run-playbook () {
  if [ ! -z "$2" ]; then
    VARS_FILE_2="--extra-vars @$2"
  else
    unset VARS_FILE_2
  fi
  PLAYBOOK="$1"
  if [ ! -e "$PLAYBOOK" ]; then
    PLAYBOOK="$PLAYBOOK.yml"
  fi
  ansible-playbook -i inventory/hosts "$PLAYBOOK" --extra-vars "@$VARS_FILE" $VARS_FILE_2 --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
}

if [ $# -ge 3 ]; then
  # run custom playbook
  run-playbook "$3" "$4"
else
  #ensure we die if any function fails
  set -e

  run-playbook "vpc"
  run-playbook "security_groups"
  run-playbook CloudFormation "vars/hosted-zone.var.yml"
  run-playbook CloudFormation "vars/database.yml"
  run-playbook "database-config"
  run-playbook CloudFormation "vars/efs.yml"
  run-playbook CloudFormation "vars/cache.yml"
  run-playbook CloudFormation "vars/waf_web_acl.var.yml"
  run-playbook "CKAN-Stack"
  run-playbook CloudFormation "vars/CKAN-extensions.yml"
  run-playbook CloudFormation "vars/CKAN-instances.yml"
  run-playbook "cloudfront"
  run-playbook "opsworks-deployment" "vars/OpsWorks-update-cookbook.var.yml"
  run-playbook "opsworks-deployment" "vars/CKAN-deployment.var.yml"
  run-playbook "opsworks-deployment" "vars/OpsWorks-configure.var.yml"
fi

