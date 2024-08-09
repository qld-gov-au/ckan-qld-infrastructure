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

REGION_SNIPPET="--region ap-southeast-2"
MESSAGE="[$COMMAND on $SERVICE $ENVIRONMENT $LAYER_NAME]"
debug "$MESSAGE: commencing..."

wait_for_deployment () {
  DEPLOYMENT_ID=$1
  debug "$MESSAGE: waiting for deployment $DEPLOYMENT_ID..."
  STATUS=$(aws ssm list-commands $REGION_SNIPPET --command-id $DEPLOYMENT_ID --query "Commands|[0].Status" --output text) || return 1
  for retry in `seq 1 180`; do
    if [ "$STATUS" = "Pending" ] || [ "$STATUS" = "InProgress" ]; then
      sleep 20
      STATUS=$(aws ssm list-commands $REGION_SNIPPET --command-id $DEPLOYMENT_ID --query "Commands|[0].Status" --output text) || return 1
      debug "Deployment $DEPLOYMENT_ID: $STATUS"
    else
      break
    fi
  done
  if [ "$STATUS" != "Success" ]; then
    debug "Failed to deploy $DEPLOYMENT_ID, status $STATUS - aborting"
    return 1
  fi
}

wait_for_instance_refresh () {
  DEPLOYMENT_ID=$1
  debug "$MESSAGE: waiting for instance refresh $DEPLOYMENT_ID..."
  STATUS=$(aws autoscaling describe-instance-refreshes $REGION_SNIPPET --auto-scaling-group-name $ASG_NAME --instance-refresh-ids $DEPLOYMENT_ID --query "InstanceRefreshes|[0].Status" --output text) || return 1
  for retry in `seq 1 180`; do
    if [ "$STATUS" = "Pending" ] || [ "$STATUS" = "InProgress" ]; then
      sleep 20
      STATUS=$(aws autoscaling describe-instance-refreshes $REGION_SNIPPET --auto-scaling-group-name $ASG_NAME --instance-refresh-ids $DEPLOYMENT_ID --query "InstanceRefreshes|[0].Status" --output text) || return 1
      debug "Instance refresh $DEPLOYMENT_ID: $STATUS"
    else
      break
    fi
  done
  if [ "$STATUS" != "Successful" ]; then
    debug "Failed instance refresh $DEPLOYMENT_ID, status $STATUS - aborting"
    return 1
  fi
}

find_load_balancer () {
  # Finds the first load balancer whose tags all match the deployment,
  # and outputs its identifying name
  for target_id in `aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName" --output text`; do
    TAGS=$(aws elb describe-tags --load-balancer-name $target_id --query "TagDescriptions[].Tags[].{Key: Key, Value: Value}[?Key=='Environment' || Key=='Service' || Key == 'Layer']" --output text)
    if (echo $TAGS | grep -E "(\s|^)Environment\s+$ENVIRONMENT(\s|$)" >/dev/null 2>&1) \
      && (echo $TAGS | grep -E "(\s|^)Service\s+$SERVICE(\s|$)" >/dev/null 2>&1) \
      && (echo $TAGS | grep -E "(\s|^)Layer\s+$LAYER_NAME(\s|$)" >/dev/null 2>&1); then
        echo "$target_id"
    fi
  done
}

find_load_balancer_v2 () {
  # Finds the first application load balancer whose tags all match the deployment,
  # and outputs its identifying name
  for target_id in `aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerArn" --output text`; do
    TAGS=$(aws elbv2 describe-tags --resource-arns $target_id --query "TagDescriptions[].Tags[].{Key: Key, Value: Value}[?Key=='Environment' || Key=='Service' || Key == 'Layer']" --output text)
    if (echo $TAGS | grep -E "(\s|^)Environment\s+$ENVIRONMENT(\s|$)" >/dev/null 2>&1) \
      && (echo $TAGS | grep -E "(\s|^)Service\s+$SERVICE(\s|$)" >/dev/null 2>&1) \
      && (echo $TAGS | grep -E "(\s|^)Layer\s+$LAYER_NAME(\s|$)" >/dev/null 2>&1); then
        echo "$target_id"
    fi
  done
}

find_autoscaling_group () {
  # Finds the first autoscaling group whose tags all match the deployment,
  # and outputs its identifying name
  for target_id in `aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[].AutoScalingGroupName" --output text`; do
    TAGS=$(aws autoscaling describe-tags --filters Name=auto-scaling-group,Values=$target_id --query "Tags[].{Key: Key, Value: Value}[?Key=='Environment' || Key=='Service' || Key == 'Layer']" --output text)
    if (echo $TAGS | grep -E "(\s|^)Environment\s+$ENVIRONMENT(\s|$)" >/dev/null 2>&1) \
      && (echo $TAGS | grep -E "(\s|^)Service\s+$SERVICE(\s|$)" >/dev/null 2>&1) \
      && (echo $TAGS | grep -E "(\s|^)Layer\s+$LAYER_NAME(\s|$)" >/dev/null 2>&1); then
        echo "$target_id"
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
  ALB_NAME=$(find_load_balancer_v2)
  debug "Application load balancer: $ALB_NAME"
  if [ "$ALB_NAME" != "" ]; then
    ASG_NAME=$(find_autoscaling_group)
    debug "Autoscaling group: $ASG_NAME"
  fi
  INSTANCE_IDS=$(aws ec2 describe-instances $REGION_SNIPPET $INSTANCE_IDENTIFIER_SNIPPET --query "Reservations[].Instances[].InstanceId" --output text) || return 1
  if [ "$INSTANCE_IDS" = "" ]; then
    if [ "$ASG_NAME" = "" ]; then
      debug "No instance(s) matching '$INSTANCE_IDENTIFIER_SNIPPET'"
      return 1
    fi
  else
    debug "Target instance(s) matching '$INSTANCE_IDENTIFIER_SNIPPET': $INSTANCE_IDS"
  fi
  if [ "$ASG_NAME" != "" ]; then
    debug "Target autoscaling group: $ASG_NAME"

    # CloudFormation does not automatically replace existing instances
    # when an ASG is updated to point to a new launch template.
    # This gives the end user flexibility in how that replacement occurs.
    #
    # If any instance is based on an obsolete launch template,
    # launch an instance refresh instead of a Chef deployment.
    ASG_TEMPLATE_VERSION=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $ASG_NAME --query "AutoScalingGroups[0].LaunchTemplate.Version" --output text)
    INSTANCE_TEMPLATE_VERSIONS=$(aws autoscaling describe-auto-scaling-instances --instance-ids $INSTANCE_IDS --query "AutoScalingInstances[].LaunchTemplate.Version" --output text)
    for instance_version in $INSTANCE_TEMPLATE_VERSIONS; do
      if [ "$instance_version" != "$ASG_TEMPLATE_VERSION" ]; then
        debug "Found an instance running launch template version $instance_version instead of $ASG_TEMPLATE_VERSION, will trigger instance refresh instead of deployment"
        REFRESH=true
        break
      fi
    done
  fi
  if [ "$REFRESH" = "true" ]; then
    INSTANCE_REFRESH_ID=$(aws autoscaling start-instance-refresh --auto-scaling-group-name $ASG_NAME --query "InstanceRefreshId" --output text)
    wait_for_instance_refresh $INSTANCE_REFRESH_ID
  elif [ "$PARALLEL" = "true" ]; then
    DEPLOYMENT_ID=$(aws ssm send-command --document-name "AWS-ApplyChefRecipes" --document-version "\$DEFAULT" --instance-ids $INSTANCE_IDS --parameters '{'"$CHEF_SOURCE"',"RunList":["'"$RUN_LIST"'"],"JsonAttributesSources":[""],"JsonAttributesContent":[""],"ChefClientVersion":["14"],"ChefClientArguments":[""],"WhyRun":["False"],"ComplianceSeverity":["None"],"ComplianceType":["Custom:Chef"],"ComplianceReportBucket":[""]}' --timeout-seconds 3600 --max-concurrency "50" --max-errors "0" --output-s3-bucket-name "osssio-ckan-web-logs" --output-s3-key-prefix "run_command" $REGION_SNIPPET --query "Command.CommandId" --output text)
    wait_for_deployment $DEPLOYMENT_ID || return 1
  else
    for instance in $INSTANCE_IDS; do
      # double-check that instance is still running
      INSTANCE_STATE=$(aws ec2 describe-instances --filters Name=instance-id,Values=$instance --query "Reservations[].Instances[0].State.Name" --output text)
      if [ "$INSTANCE_STATE" != "running" ]; then continue; fi
      if [ "$ASG_NAME" != "" ] && (aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $ASG_NAME --query "AutoScalingGroups[0].Instances[?InstanceId=='$instance' && LifecycleState=='InService'].InstanceId" --output text |grep "$instance" >/dev/null); then
        IN_ASG="true"
        # Check if the group is already at minimum capacity
        CAPACITIES=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $ASG_NAME --query "AutoScalingGroups[0].{min: MinSize, desired: DesiredCapacity}" --output text)
        CAPACITY_1=`echo $CAPACITIES | awk '{print $1}'`
        CAPACITY_2=`echo $CAPACITIES | awk '{print $2}'`
        if [ "$CAPACITY_1" = "$CAPACITY_2" ]; then
          debug "Capacity is at minimum ($CAPACITY_1 = $CAPACITY_2), new instance will be started"
          DECREMENT_BEHAVIOUR="--no-should-decrement-desired-capacity"
        else
          DECREMENT_BEHAVIOUR="--should-decrement-desired-capacity"
        fi
        # Instances in standby will not get traffic nor health checks, allowing us to update them without interruption
        OUTPUT=$(aws autoscaling enter-standby --auto-scaling-group-name "$ASG_NAME" $DECREMENT_BEHAVIOUR --instance-ids $instance --query "Activities[].Description" --output text)
        debug "$OUTPUT"
      fi
      DEPLOYMENT_ID=$(aws ssm send-command --document-name "AWS-ApplyChefRecipes" --document-version "\$DEFAULT" --instance-ids $instance --parameters '{'"$CHEF_SOURCE"',"RunList":["'"$RUN_LIST"'"],"JsonAttributesSources":[""],"JsonAttributesContent":[""],"ChefClientVersion":["14"],"ChefClientArguments":[""],"WhyRun":["False"],"ComplianceSeverity":["None"],"ComplianceType":["Custom:Chef"],"ComplianceReportBucket":[""]}' --timeout-seconds 3600 --max-concurrency "50" --max-errors "0" --output-s3-bucket-name "osssio-ckan-web-logs" --output-s3-key-prefix "run_command" --region ap-southeast-2 --query "Command.CommandId" --output text)
      DEPLOYMENT_SUCCESS=0
      wait_for_deployment $DEPLOYMENT_ID || DEPLOYMENT_SUCCESS=$?
      if [ "$IN_ASG" = "true" ]; then
        # reactivate the instance if we put it into standby
        # NB If it was in standby before we started, then we will deploy to it
        # but leave it in standby.
        OUTPUT=$(aws autoscaling exit-standby --auto-scaling-group-name "$ASG_NAME" --instance-ids $instance --query "Activities[].Description" --output text)
        debug "$OUTPUT"
      fi
      if [ "$DEPLOYMENT_SUCCESS" != "0" ]; then return 1; fi
    done
    debug "$MESSAGE: success"
  fi
}

deploy
