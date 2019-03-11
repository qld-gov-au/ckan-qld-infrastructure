#!/bin/bash
#deploy CKAN base infrastructure

VARS_FILE="$1"
ENVIRONMENT="$2"
ANSIBLE_EXTRA_VARS="$ANSIBLE_EXTRA_VARS Environment=$ENVIRONMENT"

set -x
if [ $# -ge 4 ]; then
  VARS_FILE_2="--extra-vars @$4"
fi

function run-playbook {
  if [ -z "$VARS_FILE_2" -a $# -ge 2 ]; then
    VARS_FILE_2="--extra-vars @$2"
  fi
  ansible-playbook -i inventory/hosts "$1.yml" --extra-vars "@$VARS_FILE" $VARS_FILE_2 --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
}

if [ $# -ge 3 ]; then
  # run custom playbook
  run-playbook "$3"
else
  #ensure we die if any function fails
  set -e

  run-playbook "vpc"
  run-playbook "security_groups"
  run-playbook CloudFormation "vars/database.yml"
  run-playbook "database-config"
  run-playbook CloudFormation "vars/efs.yml"
  run-playbook CloudFormation "vars/cache.yml"
  run-playbook CloudFormation "vars/waf.yml"
  run-playbook "CKAN-Stack"
  run-playbook CloudFormation "vars/CKAN-extensions.yml"
  run-playbook CloudFormation "vars/CKAN-instances.yml"
  run-playbook "cloudfront"
fi

