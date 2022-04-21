#!/bin/sh

TARGET_ENV=${DEPLOY_ENV:-DEV}
EXTENSIONS_FILE=${EXTENSIONS_FILE:-vars/shared-$VARS_TYPE.var.yml}
CKAN_VERSION=$(sed -e "/Environment: $TARGET_ENV/,/- Environment:/!d" $EXTENSIONS_FILE | grep CKANRevision |awk '{print $2}' |tr -d '"')
if [ "$CKAN_VERSION" = "" ]; then
  CKAN_VERSION=$(sed -e "/Environment: $TARGET_ENV/,/template_parameters:/!d" 'vars/CKAN-Stack.var.yml' | grep CKANRevision | awk -F: '{print $2}' |tr -d '"')
  if [ "$CKAN_VERSION" = "" ] || (echo "$CKAN_VERSION" | grep 'ckan_tag' >/dev/null); then
    CKAN_VERSION=$(grep 'ckan_tag:' 'vars/CKAN-Stack.var.yml' | awk '{print $2}' |tr -d '"')
  elif (echo "$CKAN_VERSION" | grep 'ckan_qgov_branch' >/dev/null); then
    CKAN_VERSION=$(grep 'ckan_qgov_branch:' 'vars/CKAN-Stack.var.yml' | awk '{print $2}' |tr -d '"')
  fi
fi
if [ "$CKAN_VERSION" = "" ]; then
  echo "No CKAN version found" >&2
  exit 1
fi
echo $CKAN_VERSION
