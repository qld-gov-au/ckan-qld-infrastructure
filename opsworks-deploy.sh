#!/bin/sh

if [ "$#" -lt 2 ]; then
  echo "Usage: [PARALLEL=true] $0 <command eg setup> <stack name eg OpenData_DEV> [layer name eg opendata-web] [recipe name eg datashades::ckanweb-deploy]"
  echo "When PARALLEL is true, deployments will run on all servers in the stack/layer simultaneously. This is suitable for low-impact commands like 'update_custom_cookbooks' and 'configure'."
  echo "When PARALLEL is false or not set, deployments will run on each server sequentially. This is slower, but safer, avoiding race conditions and allowing disruptive commands like 'setup' without downtime."
  exit 1
fi

COMMAND="$1"
STACK_NAME="$2"
LAYER_NAME="$3"
RECIPE_NAME="$4"

MESSAGE="Running $COMMAND"
if [ "$RECIPE_NAME" = "" ]; then
  COMMAND_SNIPPET="--command Name=$COMMAND"
else
  MESSAGE="$MESSAGE $RECIPE_NAME"
  COMMAND_SNIPPET='--command {"Name":"'"$COMMAND"'","Args":{"recipes":["'"$RECIPE_NAME"'"]}}'
fi
REGION_SNIPPET="--region us-east-1"

STACK_ID=$(aws opsworks describe-stacks $REGION_SNIPPET --query "Stacks[].{StackId:StackId, Name: Name}[?Name=='$STACK_NAME'] | [0].StackId" --output text)
MESSAGE="$MESSAGE on stack $STACK_ID"
STACK_SNIPPET="--stack-id $STACK_ID"
if [ "$LAYER_NAME" = "" ]; then
  INSTANCE_IDENTIFIER_SNIPPET="$STACK_SNIPPET"
else
  LAYER_ID=$(aws opsworks describe-layers $REGION_SNIPPET $STACK_SNIPPET --query "Layers[].{LayerId: LayerId, Shortname: Shortname}[?Shortname=='$LAYER_NAME']|[0].LayerId" --output text)
  MESSAGE="$MESSAGE, layer $LAYER_ID"
  LAYER_SNIPPET="--layer-id $LAYER_ID"
  INSTANCE_IDENTIFIER_SNIPPET="$LAYER_SNIPPET"
fi

echo "$MESSAGE"

wait_for_deployment () {
  DEPLOYMENT_ID=$1
  STATUS=$(aws opsworks describe-deployments $REGION_SNIPPET --deployment-id $DEPLOYMENT_ID --query "Deployments|[0].Status" --output text) || exit 1
  for retry in `seq 1 90`; do
    if [ "$STATUS" = "running" ]; then
      sleep 10
      STATUS=$(aws opsworks describe-deployments $REGION_SNIPPET --deployment-id $DEPLOYMENT_ID --query "Deployments|[0].Status" --output text) || exit 1
      echo "Deployment $DEPLOYMENT_ID: $STATUS"
    fi
  done
  if [ "$STATUS" != "successful" ]; then
    echo "Failed to deploy, status $STATUS - aborting"
    exit 1
  fi
}

for truthy in `echo "y t T 1" |xargs echo`; do
  if [ "$PARALLEL" = "$truthy" ]; then
    echo "Parallel enabled, will deploy to entire stack/layer simultaneously"
    PARALLEL=true
  fi
done
if [ "$PARALLEL" = "true" ]; then
  DEPLOYMENT_ID=$(aws opsworks create-deployment $REGION_SNIPPET $STACK_SNIPPET $LAYER_SNIPPET $COMMAND_SNIPPET --output text)
  wait_for_deployment $DEPLOYMENT_ID || exit 1
else
  INSTANCE_IDS=$(aws opsworks describe-instances $REGION_SNIPPET $INSTANCE_IDENTIFIER_SNIPPET --query "Instances[].{Id: InstanceId, Status: Status}[?Status=='online'||Status=='setup_failed']|[].Id" --output text) || exit 1
  echo "Target instance(s): $INSTANCE_IDS"
  for instance in $INSTANCE_IDS; do
    DEPLOYMENT_ID=$(aws opsworks create-deployment $REGION_SNIPPET $STACK_SNIPPET --instance-id $instance $COMMAND_SNIPPET --output text)
    wait_for_deployment $DEPLOYMENT_ID || exit 1
    # wait for load balancer health checks to complete
    # TODO Use 'aws elb describe-instance-health' to properly monitor
    sleep 60
  done
fi
echo "Deployment successful"
