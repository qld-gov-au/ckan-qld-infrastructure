#!/bin/sh

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <command eg setup> <stack name eg OpenData_DEV> [layer name eg opendata-web] [recipe name eg datashades::ckanweb-deploy]"
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
  INSTANCE_IDENTIFIER_SNIPPET="--layer-id $LAYER_ID"
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

if [ "$PARALLEL" = "1" ]; then
  DEPLOYMENT_ID=$(aws opsworks create-deployment $REGION_SNIPPET $INSTANCE_IDENTIFIER_SNIPPET $COMMAND_SNIPPET --output text)
  wait_for_deployment $DEPLOYMENT_ID || exit 1
else
  INSTANCE_IDS=$(aws opsworks describe-instances $REGION_SNIPPET $INSTANCE_IDENTIFIER_SNIPPET --query "Instances[].{Id: InstanceId, Status: Status}[?Status=='online']|[].Id" --output text)
  echo "Target instance(s): $INSTANCE_IDS"
  for instance in $INSTANCE_IDS; do
    DEPLOYMENT_ID=$(aws opsworks create-deployment $REGION_SNIPPET $STACK_SNIPPET --instance-id $instance $COMMAND_SNIPPET --output text)
    wait_for_deployment $DEPLOYMENT_ID || exit 1
  done
fi
echo "Deployment successful"
