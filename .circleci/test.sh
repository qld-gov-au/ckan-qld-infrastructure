#!/usr/bin/env bash
##
# Run tests in CI.
#
set -e

echo "==> Lint code"
ahoy lint || exit 1

echo "==> Run Unit tests"
ahoy test-unit || exit 1

echo "==> Run BDD tests"
ahoy test-bdd || exit 1
