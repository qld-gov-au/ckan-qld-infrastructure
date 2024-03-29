#!/bin/sh

set -e

debug () {
    echo "$1" >&2
}

if [ "$#" -lt 3 ]; then
  debug "Usage: [PARALLEL=true] $0 <command eg setup> <service eg OpenData> [environment eg DEV] [layer eg web] [recipe name eg datashades::ckanweb-deploy]"
  debug "When PARALLEL is true, deployments will run on all servers in the stack/layer simultaneously. This is suitable for low-impact commands like 'configure'."
  debug "When PARALLEL is false or not set, deployments will run on each server sequentially. This is slower, but safer, avoiding race conditions and allowing disruptive commands like 'setup' without downtime."
  exit 1
fi

COMMAND="$1"
SERVICE="$2"
ENVIRONMENT="$3"
LAYER_NAME="$4"
RUN_LIST="recipe[$(echo $COMMAND | sed 's/,/],recipe[/g')]"

# Retrieve generated custom JSON
CHEF_SOURCE=$(cat templates/chef-source.json | tr -d '\n')
CUSTOM_JSON=$(cat templates/chef.json | tr -d '\n' | sed 's/"/\\"/g')

REGION_SNIPPET="--region ap-southeast-2"
MESSAGE="[$COMMAND on $SERVICE $ENVIRONMENT $LAYER_NAME]"
debug "$MESSAGE: commencing..."

wait_for_deployment () {
  DEPLOYMENT_ID=$1
  debug "$MESSAGE: waiting for deployment $DEPLOYMENT_ID..."
  STATUS=$(aws ssm list-commands $REGION_SNIPPET --command-id $DEPLOYMENT_ID --query "Commands|[0].Status" --output text) || exit 1
  for retry in `seq 1 180`; do
    if [ "$STATUS" = "Pending" ] || [ "$STATUS" = "InProgress" ]; then
      sleep 10
      STATUS=$(aws ssm list-commands $REGION_SNIPPET --command-id $DEPLOYMENT_ID --query "Commands|[0].Status" --output text) || exit 1
      debug "Deployment $DEPLOYMENT_ID: $STATUS"
    else
      break
    fi
  done
  if [ "$STATUS" != "Success" ]; then
    debug "Failed to deploy $DEPLOYMENT_ID, status $STATUS - aborting"
    exit 1
  fi
}

find_load_balancer () {
  # Finds the first load balancer whose tags all match the deployment,
  # and outputs its identifying name
  for lb_name in `aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName" --output text`; do
    LB_TAGS=$(aws elb describe-tags --load-balancer-name $lb_name --query "TagDescriptions[].Tags[].{Key: Key, Value: Value}[?Key=='Environment' || Key=='Service' || Key == 'Layer']" --output text)
    if (echo $LB_TAGS | grep -E "(\s|^)Environment\s+$ENVIRONMENT(\s|$)" >/dev/null 2>&1) \
      && (echo $LB_TAGS | grep -E "(\s|^)Service\s+$SERVICE(\s|$)" >/dev/null 2>&1) \
      && (echo $LB_TAGS | grep -E "(\s|^)Layer\s+$LAYER_NAME(\s|$)" >/dev/null 2>&1); then
        echo "$lb_name"
    fi
  done
}

deploy () {
  for truthy in `echo "y t true T 1" |xargs echo`; do
    if [ "$PARALLEL" = "$truthy" ]; then
      debug "$MESSAGE: Parallel enabled, will deploy to all target instances simultaneously"
      PARALLEL=true
    fi
  done

  INSTANCE_IDENTIFIER_SNIPPET="--filters Name=tag:Environment,Values=$ENVIRONMENT Name=tag:Service,Values=$SERVICE Name=instance-state-name,Values=running"
  if [ "$LAYER_NAME" != "" ]; then
      INSTANCE_IDENTIFIER_SNIPPET="${INSTANCE_IDENTIFIER_SNIPPET} Name=tag:Layer,Values=$LAYER_NAME"
  fi
  INSTANCE_IDS=$(aws ec2 describe-instances $REGION_SNIPPET $INSTANCE_IDENTIFIER_SNIPPET --query "Reservations[].Instances[].InstanceId" --output text) || exit 1
  if [ "$INSTANCE_IDS" = "" ]; then
    debug "No eligible instance(s) in $SERVICE $ENVIRONMENT $LAYER_NAME"
    exit 1
  else
    debug "Target instance(s) in $SERVICE $ENVIRONMENT $LAYER_NAME: $INSTANCE_IDS"
  fi
  if [ "$PARALLEL" = "true" ]; then
    DEPLOYMENT_ID=$(aws ssm send-command --document-name "AWS-ApplyChefRecipes" --document-version "\$DEFAULT" --instance-ids $INSTANCE_IDS --parameters '{'"$CHEF_SOURCE"',"RunList":["'"$RUN_LIST"'"],"JsonAttributesSources":[""],"JsonAttributesContent":["'"$CUSTOM_JSON"'"],"ChefClientVersion":["14"],"ChefClientArguments":[""],"WhyRun":["False"],"ComplianceSeverity":["None"],"ComplianceType":["Custom:Chef"],"ComplianceReportBucket":[""]}' --timeout-seconds 3600 --max-concurrency "50" --max-errors "0" --output-s3-bucket-name "osssio-ckan-web-logs" --output-s3-key-prefix "run_command" --region ap-southeast-2 --query "Command.CommandId" --output text)
    wait_for_deployment $DEPLOYMENT_ID || exit 1
  else
    ELB_NAME=$(find_load_balancer)
    for instance in $INSTANCE_IDS; do
      if [ "$ELB_NAME" != "" ]; then
        OUTPUT=$(aws elb deregister-instances-from-load-balancer --load-balancer-name "$ELB_NAME" --instances "$instance" --query "Instances[].InstanceId" --output text)
        debug "Deregistered instance $instance from load balancer $ELB_NAME, resulting registered instances: $OUTPUT"
      fi
      DEPLOYMENT_ID=$(aws ssm send-command --document-name "AWS-ApplyChefRecipes" --document-version "\$DEFAULT" --instance-ids $instance --parameters '{'"$CHEF_SOURCE"',"RunList":["'"$RUN_LIST"'"],"JsonAttributesSources":[""],"JsonAttributesContent":["'"$CUSTOM_JSON"'"],"ChefClientVersion":["14"],"ChefClientArguments":[""],"WhyRun":["False"],"ComplianceSeverity":["None"],"ComplianceType":["Custom:Chef"],"ComplianceReportBucket":[""]}' --timeout-seconds 3600 --max-concurrency "50" --max-errors "0" --output-s3-bucket-name "osssio-ckan-web-logs" --output-s3-key-prefix "run_command" --region ap-southeast-2 --query "Command.CommandId" --output text)
      wait_for_deployment $DEPLOYMENT_ID
      DEPLOYMENT_SUCCESS=$?
      if [ "$ELB_NAME" != "" ]; then
        OUTPUT=$(aws elb register-instances-with-load-balancer --load-balancer-name "$ELB_NAME" --instances "$instance" --query "Instances[].InstanceId" --output text)
        debug "Registered instance with load balancer $ELB_NAME, resulting registered instances: $OUTPUT"
      fi
      if [ "$DEPLOYMENT_SUCCESS" != "0" ]; then exit 1; fi
    done
    debug "$MESSAGE: success"
  fi
}

deploy
