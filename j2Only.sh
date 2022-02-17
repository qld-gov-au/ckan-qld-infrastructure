#!/bin/bash

set -eux

#!/bin/bash
#deploy Open Data base infrastructure

if [ "$bamboo_deploy_environment" = "" ]; then
  echo "Missing bamboo_deploy_environment" >&2
  exit 1
fi
INSTANCE_NAME=OpenData
INSTANCE_SHORTNAME=`echo $INSTANCE_NAME |tr '[A-Z]' '[a-z]'`
STACK_NAME="${INSTANCE_NAME}_$bamboo_deploy_environment"

## Common Bamboo Variables ##
BUILD=xx
bamboo_planRepository_branch=xx
bamboo_deploy_version=xx
bamboo_planRepository_revision=xx
ENVIRONMENT="$(echo $bamboo_deploy_environment | sed 's/-TEARDOWN//')"

ANSIBLE_EXTRA_VARS="Environment=$ENVIRONMENT Build=$BUILD BuildBranch=$bamboo_planRepository_branch DeployVersion=$bamboo_deploy_version BuildRevision=$bamboo_planRepository_revision"
VARS_FILE="vars/shared-$INSTANCE_NAME.var.yml"

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



run-playbook "j2Only" "vars/${INSTANCE_NAME}-instances.var.yml"
