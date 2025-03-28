#!/bin/bash
#deploy CKAN base infrastructure

#ensure we die if any function fails
set -ex

VARS_FILE="$1"
ENVIRONMENT="$2"
ANSIBLE_EXTRA_VARS="$ANSIBLE_EXTRA_VARS Environment=$ENVIRONMENT"

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
  run-playbook "chef-json"
  PARALLEL=1 ./chef-deploy.sh datashades::ckanweb-configure $INSTANCE_NAME $ENVIRONMENT web & WEB_PID=$!
  # Check if the web deployment immediately failed
  kill -0 $WEB_PID
  PARALLEL=1 ./chef-deploy.sh datashades::ckanbatch-configure $INSTANCE_NAME $ENVIRONMENT batch & BATCH_PID=$!
  wait $WEB_PID
  wait $BATCH_PID
  ./chef-deploy.sh datashades::solr-configure $INSTANCE_NAME $ENVIRONMENT solr || exit 1
}

create-amis () {
  run-playbook "AMI-templates.yml" "state=absent"
  # try to match an existing image instead of creating a new one
  if [ "$IMAGE_VERSION" = "" ]; then
    IMAGE_VERSION=`git rev-parse HEAD` || true
  fi
  if [ "$IMAGE_VERSION" = "" ]; then
    AMI_NEEDED=1
  else
    for layer in Web Batch Solr; do
      lowercase_layer=`echo $layer | tr '[:upper:]' '[:lower:]'`
      echo "Checking for existing $ENVIRONMENT $INSTANCE_NAME $lowercase_layer image tagged with version ${IMAGE_VERSION}..."
      IMAGE_ID=$(aws ec2 describe-images --filters "Name=tag:Environment,Values=$ENVIRONMENT" "Name=tag:Service,Values=$INSTANCE_NAME" "Name=tag:Version,Values=$IMAGE_VERSION" "Name=tag:Layer,Values=$lowercase_layer" --query "Images[].ImageId" --output text |tail -1 |tr -d '[:space:]')
      if [ "$IMAGE_ID" = "" ]; then
        AMI_NEEDED=1
      else
        echo "Found existing image(s): $IMAGE_ID"
        aws ssm put-parameter --overwrite --type String --name "/config/CKAN/$ENVIRONMENT/app/$INSTANCE_SHORTNAME/${layer}AmiId" --value "$IMAGE_ID"
        eval "${layer}_IMAGE_ID=$IMAGE_ID"
      fi
    done
  fi
  if [ "$AMI_NEEDED" != "1" ]; then
    echo "All machine images found, skipping generation"
    return 0
  fi
  echo "Generating custom machine image(s)..."
  run-playbook "AMI-templates.yml"
  ANSIBLE_EXTRA_VARS="$ANSIBLE_EXTRA_VARS timestamp=`date -u +%Y-%m-%dT%H:%M:%SZ` image_version=$IMAGE_VERSION"
  for layer in Batch Web Solr; do
    eval "image=\$${layer}_IMAGE_ID"
    if [ "$image" = "" ]; then
      run-playbook "create-AMI" "layer=$layer" & eval "${layer}_PID=$!"
    fi
  done
  for layer in Batch Web Solr; do
    eval "PID=\$${layer}_PID"
    if [ "$PID" != "" ]; then
      wait "$PID" || exit 1
    fi
  done
  run-playbook "AMI-templates.yml" "state=absent"
}

run-all-playbooks () {
  run-shared-resource-playbooks
  run-playbook "CloudFormation" "vars/acm.var.yml"
  if [ "$SKIP_CKAN_DB" != "true" ]; then
    run-playbook "database-config"
  fi
  run-playbook "CloudFormation" "vars/s3_buckets.var.yml"
  run-playbook "CKAN-Stack"
  run-playbook "CloudFormation" "vars/CKAN-extensions.var.yml"
  if ! (create-amis); then
    ANSIBLE_EXTRA_VARS="$ANSIBLE_EXTRA_VARS state=absent" run-playbook "CloudFormation" "vars/AMI-template-instances.var.yml" || exit 1
    exit 1
  fi
  run-playbook "CloudFormation" "vars/instances-${INSTANCE_NAME}.var.yml"
  run-playbook "CloudFormation" "vars/cloudfront-lambda-at-edge.var.yml"
  run-playbook "cloudfront"
  run-deployment
}

if [ $# -ge 3 ]; then
  if [ "$3" = "deploy" ]; then
    run-deployment
  elif [ "$3" = "setup" ]; then
    run-playbook "chef-json"
    PARALLEL=1 ./chef-deploy.sh datashades::ckanweb-setup,datashades::ckanweb-deploy,datashades::ckanweb-configure $INSTANCE_NAME $ENVIRONMENT web & WEB_PID=$!
    PARALLEL=1 ./chef-deploy.sh datashades::ckanbatch-setup,datashades::ckanbatch-deploy,datashades::ckanbatch-configure $INSTANCE_NAME $ENVIRONMENT batch & BATCH_PID=$!
    PARALLEL=1 ./chef-deploy.sh datashades::solr-setup,datashades::solr-deploy,datashades::solr-configure $INSTANCE_NAME $ENVIRONMENT solr
    wait $WEB_PID
    wait $BATCH_PID
  elif [ "$3" = "configure" ]; then
    run-playbook "chef-json"
    PARALLEL=1 ./chef-deploy.sh datashades::ckanweb-configure $INSTANCE_NAME $ENVIRONMENT web & WEB_PID=$!
    PARALLEL=1 ./chef-deploy.sh datashades::ckanbatch-configure $INSTANCE_NAME $ENVIRONMENT batch & BATCH_PID=$!
    PARALLEL=1 ./chef-deploy.sh datashades::solr-configure $INSTANCE_NAME $ENVIRONMENT solr
    wait $WEB_PID
    wait $BATCH_PID
  elif [ "$3" = "create-amis" ]; then
    create-amis
  else
    # run custom playbook
    run-playbook "$3" "$4"
  fi
else
  run-all-playbooks
fi

