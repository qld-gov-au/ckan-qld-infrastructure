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

if [ $# -ge 3 ]; then
  # run custom playbook
  run-playbook "$3" "$4"
else
  run-all-playbooks
fi

