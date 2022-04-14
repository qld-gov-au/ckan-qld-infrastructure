#!/bin/sh

TARGET_ENV=${DEPLOY_ENV:-DEV}
EXTENSIONS_FILE=${EXTENSIONS_FILE:-vars/shared-$VARS_TYPE.var.yml}
sed -e "/Environment: $TARGET_ENV/,/- Environment:/!d" $EXTENSIONS_FILE | grep CKANRevision |awk '{print $2}' |tr -d '"'
