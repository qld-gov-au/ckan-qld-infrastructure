#!/usr/bin/env bash
##
# Run tests in CI.
#
set -e

SCRIPT_DIR=`dirname $0`

$SCRIPT_DIR/test-lint.sh

$SCRIPT_DIR/test.sh

$SCRIPT_DIR/test-bdd.sh
