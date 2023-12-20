#!/bin/sh

set -e

debug () {
    echo "$1" >&2
}

if [ "$#" -lt 2 ]; then
  debug "Usage: [PARALLEL=true] $0 <command eg setup> <stack name eg OpenData_DEV> [layer name eg opendata-web] [recipe name eg datashades::ckanweb-deploy]"
  debug "When PARALLEL is true, deployments will run on all servers in the stack/layer simultaneously. This is suitable for low-impact commands like 'update_custom_cookbooks' and 'configure'."
  debug "When PARALLEL is false or not set, deployments will run on each server sequentially. This is slower, but safer, avoiding race conditions and allowing disruptive commands like 'setup' without downtime."
  exit 1
fi

COMMAND="$1"
STACK_NAME="$2"
LAYER_NAME="$3"
RECIPE_NAME="$4"

MESSAGE="[$COMMAND"
if [ "$RECIPE_NAME" = "" ]; then
  COMMAND_SNIPPET="--command Name=$COMMAND"
else
  MESSAGE="$MESSAGE $RECIPE_NAME"
  COMMAND_SNIPPET='--command {"Name":"'"$COMMAND"'","Args":{"recipes":["'"$RECIPE_NAME"'"]}}'
fi
REGION_SNIPPET="--region us-east-1"

STACK_ID=$(aws opsworks describe-stacks $REGION_SNIPPET --query "Stacks[].{StackId:StackId, Name: Name}[?Name=='$STACK_NAME'] | [0].StackId" --output text)
MESSAGE="$MESSAGE on stack $STACK_NAME"
STACK_SNIPPET="--stack-id $STACK_ID"
if [ "$LAYER_NAME" = "" ]; then
  INSTANCE_IDENTIFIER_SNIPPET="$STACK_SNIPPET"
else
  LAYER_ID=$(aws opsworks describe-layers $REGION_SNIPPET $STACK_SNIPPET --query "Layers[].{LayerId: LayerId, Shortname: Shortname}[?Shortname=='$LAYER_NAME']|[0].LayerId" --output text)
  debug "Layer name $LAYER_NAME resolves to $LAYER_ID"
  MESSAGE="$MESSAGE, layer $LAYER_NAME"
  LAYER_SNIPPET="--layer-id $LAYER_ID"
  INSTANCE_IDENTIFIER_SNIPPET="$LAYER_SNIPPET"
fi

MESSAGE="$MESSAGE]"
debug "$MESSAGE: commencing..."

wait_for_deployment () {
  DEPLOYMENT_ID=$1
  debug "$MESSAGE: waiting for deployment $DEPLOYMENT_ID..."
  STATUS=$(aws opsworks describe-deployments $REGION_SNIPPET --deployment-id $DEPLOYMENT_ID --query "Deployments|[0].Status" --output text) || exit 1
  for retry in `seq 1 180`; do
    if [ "$STATUS" = "running" ]; then
      sleep 10
      STATUS=$(aws opsworks describe-deployments $REGION_SNIPPET --deployment-id $DEPLOYMENT_ID --query "Deployments|[0].Status" --output text) || exit 1
      debug "Deployment $DEPLOYMENT_ID: $STATUS"
    fi
  done
  if [ "$STATUS" != "successful" ]; then
    debug "Failed to deploy $DEPLOYMENT_ID, status $STATUS - aborting"
    exit 1
  fi
}

deploy () {
  for truthy in `echo "y t T 1" |xargs echo`; do
    if [ "$PARALLEL" = "$truthy" ]; then
      debug "$MESSAGE: Parallel enabled, will deploy to entire stack/layer simultaneously"
      PARALLEL=true
    fi
  done
  INSTANCE_IDS=$(aws opsworks describe-instances $REGION_SNIPPET $INSTANCE_IDENTIFIER_SNIPPET --query "Instances[].{Id: InstanceId, Status: Status}[?Status=='online'||Status=='setup_failed']|[].Id" --output text) || exit 1
  if [ "$INSTANCE_IDS" = "" ]; then
    debug "No eligible instance(s) in $INSTANCE_IDENTIFIER_SNIPPET"
  else
    debug "Target instance(s) in $INSTANCE_IDENTIFIER_SNIPPET: $INSTANCE_IDS"
    if [ "$PARALLEL" = "true" ]; then
      DEPLOYMENT_ID=$(aws opsworks create-deployment $REGION_SNIPPET $STACK_SNIPPET $LAYER_SNIPPET $COMMAND_SNIPPET --output text)
      wait_for_deployment $DEPLOYMENT_ID || exit 1
    else
      for instance in $INSTANCE_IDS; do
        DEPLOYMENT_ID=$(aws opsworks create-deployment $REGION_SNIPPET $STACK_SNIPPET --instance-id $instance $COMMAND_SNIPPET --output text)
        wait_for_deployment $DEPLOYMENT_ID || exit 1
        # wait for load balancer health checks to complete
        # TODO Use 'aws elb describe-instance-health' to properly monitor
        sleep 60
      done
    fi
    debug "$MESSAGE: success"
  fi
}

wait_for_instance_status () {
  INSTANCE_ID=$1
  TARGET_STATUS=$2
  debug "$MESSAGE: waiting for instance $INSTANCE_ID..."
  STATUS=$(aws opsworks describe-instances $REGION_SNIPPET --instance-id=$INSTANCE_ID --query "Instances[].{Id: InstanceId, Status: Status}[?Id=='$INSTANCE_ID']|[].Status" --output text) || exit 1
  for retry in `seq 1 90`; do
    if [ "$STATUS" != "$TARGET_STATUS" ]; then
      sleep 10
      STATUS=$(aws opsworks describe-instances $REGION_SNIPPET --instance-id=$INSTANCE_ID --query "Instances[].{Id: InstanceId, Status: Status}[?Id=='$INSTANCE_ID']|[].Status" --output text) || exit 1
      debug "Instance $INSTANCE_ID: $STATUS"
    fi
  done
  if [ "$STATUS" != "$TARGET_STATUS" ]; then
    debug "$INSTANCE_ID has status '$STATUS' instead of '$TARGET_STATUS' - aborting"
    exit 1
  fi
}

get_stopped_instances () {
  aws opsworks describe-instances $REGION_SNIPPET $INSTANCE_IDENTIFIER_SNIPPET --query "Instances[].{Hostname: Hostname, Status: Status}[?Status=='stopped']|[].Hostname" --output text
}

start_servers () {
  debug "Starting all stopped instances in $INSTANCE_IDENTIFIER_SNIPPET..."
  INSTANCE_IDS=$(aws opsworks describe-instances $REGION_SNIPPET $INSTANCE_IDENTIFIER_SNIPPET --query "Instances[].{Id: InstanceId, Status: Status}[?Status=='stopped']|[].Id" --output text) || exit 1
  if [ "$INSTANCE_IDS" = "" ]; then
    debug "No eligible instance(s) in $INSTANCE_IDENTIFIER_SNIPPET"
  else
    debug "Target instance(s) in $INSTANCE_IDENTIFIER_SNIPPET: $INSTANCE_IDS"
    for instance in $INSTANCE_IDS; do
      aws opsworks start-instance $REGION_SNIPPET --instance-id $instance
    done
    for instance in $INSTANCE_IDS; do
      wait_for_instance_status $instance online
    done
    debug "$MESSAGE: success"
  fi
}

stop_servers () {
  INSTANCES="$1"
  debug "Stopping instances $INSTANCES..."
  INSTANCE_IDS=
  for instance in $INSTANCES; do
    debug "Looking up ID for instance $instance..."
    INSTANCE_IDS="$INSTANCE_IDS $(aws opsworks describe-instances $REGION_SNIPPET $INSTANCE_IDENTIFIER_SNIPPET --query "Instances[].{Id: InstanceId, Name: Hostname, Status: Status}[?Name=='$instance'&&Status=='online']|[].Id" --output text)"
  done
  debug "Eligible instance(s): '$INSTANCE_IDS'"
  TRIMMED_IDS=$(echo "$INSTANCE_IDS" | tr -d '[:space:]')
  if [ "$TRIMMED_IDS" = "" ]; then
    debug "No eligible instance(s) in $INSTANCE_IDENTIFIER_SNIPPET"
  else
    debug "Target instance(s) in $INSTANCE_IDENTIFIER_SNIPPET: $INSTANCE_IDS"
    for instance in $INSTANCE_IDS; do
      echo "$PRESERVE_INSTANCE_IDS" |grep "$instance" || \
        aws opsworks stop-instance $REGION_SNIPPET --instance-id $instance
    done
    for instance in $INSTANCE_IDS; do
      echo "$PRESERVE_INSTANCE_IDS" |grep "$instance" || \
        wait_for_instance_status $instance stopped
    done
    debug "$MESSAGE: success"
  fi
}

if [ "$COMMAND" = "start" ]; then
  start_servers
elif [ "$COMMAND" = "stop" ]; then
  stop_servers "$RECIPE_NAME"
elif [ "$COMMAND" = "get_stopped_instances" ]; then
  get_stopped_instances
else
  deploy
fi
