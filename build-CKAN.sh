#!/bin/bash
#deploy CKAN base infrastructure

#ensure we die if any function fails
set -ex

VARS_FILE="$1"
ENVIRONMENT="$2"
export ANSIBLE_EXTRA_VARS="$ANSIBLE_EXTRA_VARS Environment=$ENVIRONMENT"

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

# Switch off ELB health checks while changing core components like the database,
# which can cause health check errors but the EC2 instances don't need replacement.
set_health_checks () {
  CHECK_TYPE=EC2
  for truthy in `echo "y t true T 1" |xargs echo`; do
    if [ "$1" = "$truthy" ]; then
      CHECK_TYPE=ELB
      break
    fi
  done

  for APP_NAME in `echo "OpenData Publications CKANTest"`; do
    # configure health checks for every app since components are shared,
    # but skip any app that doesn't exist in this environment,
    # ie CKANTest only exists up to TRAINING.
    ASG_NAME="${ENVIRONMENT}-${APP_NAME}-Web-ASG"
    echo "Setting health check type for $ASG_NAME to ${CHECK_TYPE}..."
    aws autoscaling update-auto-scaling-group --region ap-southeast-2 --auto-scaling-group-name "$ASG_NAME" --health-check-type "$CHECK_TYPE" || continue
  done
}

run-shared-resource-playbooks () {
  set_health_checks false
  run-playbook "vpc"
  run-playbook "CloudFormation" "vars/security_groups.var.yml"
  run-playbook "CloudFormation" "vars/hosted-zone.var.yml"
  run-playbook "CloudFormation" "vars/database.var.yml"
  run-playbook "CloudFormation" "vars/efs.var.yml"
  run-playbook "CloudFormation" "vars/cache.var.yml"
  run-playbook "CloudFormation" "vars/waf_web_acl.var.yml"
  set_health_checks true
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

create-baseline-ami () {
  # Amazon Linux 2023 AMI 2023.11.20260413.0 arm64 HVM kernel-6.1
  VANILLA_IMAGE_ID="ami-0b1336cc21eaf94c5"
  LATEST_VANILLA_IMAGE=$(aws ec2 describe-images --filters "Name=name,Values=al2023-ami-2023*-arm64" --query "Images[].[Name, ImageId]" --output text |sort |tail -1 |cut -f 2)
  if [ "$VANILLA_IMAGE_ID" != "LATEST_VANILLA_IMAGE" ]; then
    echo "Using $VANILLA_IMAGE_ID; however, a newer operating system image exists, $LATEST_VANILLA_IMAGE"
  fi
  BASELINE_IMAGE_ID=$(aws ssm get-parameter --name "/config/CKAN/$ENVIRONMENT/common/BaselineAmiId" --query "Parameter.Value" --output text)
  if [ "$BASELINE_IMAGE_ID" != "" ]; then
    # check if the image is still current
    PREVIOUS_VANILLA_IMAGE=$(aws ec2 describe-tags --filters "Name=resource-type,Values=image" "Name=resource-id,Values=$BASELINE_IMAGE_ID" --query "Tags[?Key=='Version']|[0].Value" --output text)
    if [ "$VANILLA_IMAGE_ID" = "$PREVIOUS_VANILLA_IMAGE" ]; then
      echo "Baseline image is unchanged"
      return 0
    fi
  fi
  SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters "Name=tag:Environment,Values=$ENVIRONMENT" "Name=tag:Service,Values=CKAN" \
    --query "SecurityGroups[0].GroupId" --output text)
  INSTANCE_PROFILE_NAME=$(aws iam list-instance-profiles \
    --query "InstanceProfiles[?contains(InstanceProfileName, 'WebInstanceRole')]|[0].InstanceProfileName" --output text)
  SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=tag:Environment,Values=$ENVIRONMENT" "Name=tag:Service,Values=CKAN" \
    --query "Subnets[0].SubnetId" --output text)
  USER_DATA=$(cat <<'PARAMETER_STRING'
#!/bin/sh
OMNITRUCK_URL="https://omnitruck.chef.io/stable/chef/metadata?v=18.8&p=el&pv=8&m=aarch64"
RPM_URL=$(curl "$OMNITRUCK_URL" |tail -2 |head -1 |awk '{print $2}')
dnf install -y libxcrypt-compat $RPM_URL && shutdown -P now
PARAMETER_STRING
  )
  INSTANCE_ID=$(aws ec2 run-instances --image-id "$VANILLA_IMAGE_ID" --instance-type t4g.nano --iam-instance-profile "Name=$INSTANCE_PROFILE_NAME" --security-group-ids "$SECURITY_GROUP_ID" \
    --subnet-id "$SUBNET_ID" --user-data "$USER_DATA" \
    --query "Instances[0].InstanceId" --output text)
  if [ "$INSTANCE_ID" = "" ]; then
    echo "Failed to start template instance" >&2
    return 1
  fi

  echo "Launched template instance $INSTANCE_ID, waiting for successful configuration and self-shutdown..." >&2

  STATUS=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[].Instances[].State.Name" --output text) || return 1
  echo "Instance $INSTANCE_ID status: $STATUS" >&2
  for retry in `seq 1 20`; do
    if [ "$STATUS" = "stopped" ]; then
      break
    else
      sleep 10
      STATUS=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[].Instances[].State.Name" --output text) || return 1
      echo "Instance $INSTANCE_ID status: $STATUS" >&2
    fi
  done
  if [ "$STATUS" != "stopped" ]; then
    echo "$INSTANCE_ID failed to prepare and shut down, status $STATUS - aborting" >&2
    exit 2
  fi

  echo "Instance $INSTANCE_ID is ready, generating image..." >&2

  AMI_ID=$(aws ec2 create-image --instance-id "$INSTANCE_ID" --no-reboot \
    --name "${ENVIRONMENT}-chef-preinstalled-image-from-${VANILLA_IMAGE_ID}" \
    --description "Baseline AMI for CKAN instances, built from $VANILLA_IMAGE_ID plus Chef" \
    --tag-specifications "ResourceType=image,Tags=[{Key=Version,Value=${VANILLA_IMAGE_ID}}]" \
    --query "ImageId" --output text
  )
  if [ "$AMI_ID" = "" ]; then
    echo "Failed to create image, you may wish to investigate $INSTANCE_ID and manually terminate it!" >&2
    return 1
  fi
  aws ec2 wait image-available --image-ids "$AMI_ID" || return 1

  echo "Recording new baseline image ID: $AMI_ID" >&2

  aws ssm put-parameter --overwrite --type String --name "/config/CKAN/$ENVIRONMENT/common/BaselineAmiId" --value "$AMI_ID" || return 1

  echo "Cleaning up..." >&2

  aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" && return 0

  echo "Failed to terminate ${INSTANCE_ID}! This may need manual intervention." >&2
  return 1
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
        echo "No $layer image found, will generate"
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
  run-playbook "AMI-templates.yml" || exit 1
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
  if ! (create-baseline-ami); then
    echo "Failed to create baseline AMI" >&2
    exit 1
  fi
  run-playbook "CloudFormation" "vars/CKAN-extensions.var.yml"
  if ! (create-amis); then
    echo "Failed to create machine images for $INSTANCE_NAME" >&2
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
    create-baseline-ami && create-amis
  else
    # run custom playbook
    run-playbook "$3" "$4"
  fi
else
  run-all-playbooks
fi

