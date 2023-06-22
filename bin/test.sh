#!/usr/bin/env bash
##
# Run tests in CI.
#
set -e

echo "==> Run Unit tests"
ahoy test-unit
