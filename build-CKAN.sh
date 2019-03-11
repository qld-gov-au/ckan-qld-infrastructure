#!/bin/bash
#deploy CKAN base infrastructure

VARS_FILE="$1"
ENVIRONMENT="$2"
ANSIBLE_EXTRA_VARS="$ANSIBLE_EXTRA_VARS Environment=$ENVIRONMENT"

function run-playbook {
  ansible-playbook -i inventory/hosts "$1.yml" --extra-vars "@$VARS_FILE" --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
}

if [ $# -ge 3 ]; then
  # run custom playbook
  run-playbook "$3"
else
  #ensure we die if any function fails
  set -e

  run-playbook "vpc"
  run-playbook "security_groups"
  run-playbook "database"
  run-playbook "database-config"
  run-playbook "efs"
  run-playbook "cache"
  run-playbook "waf"
  run-playbook "CKAN-Stack"
  run-playbook "CKAN-extensions"
  run-playbook "CKAN-instances"
  run-playbook "cloudfront"
fi

