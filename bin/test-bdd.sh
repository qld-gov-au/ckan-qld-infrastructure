#!/usr/bin/env bash
##
# Run tests in CI.
#
set -ex

ahoy install-site
echo "==> Run BDD tests"
ahoy test-bdd
