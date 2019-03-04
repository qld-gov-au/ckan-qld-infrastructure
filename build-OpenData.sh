#!/bin/bash
#deploy CKAN base infrastructure

ANSIBLE_EXTRA_VARS="$ANSIBLE_EXTRA_VARS region=ap-southeast-2 Environment=$bamboo_deploy_environment titlecase_name=OpenData lowercase_name=opendata enable_datastore=yes"

function run-playbook {
  ansible-playbook -i inventory/hosts "$1.yml" --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
}

if [ $# -ge 1 ]; then
  # run custom playbook
  run-playbook "$1"
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

