#!/usr/bin/env bash
##
# Run tests in CI.
#
set -ex

ahoy install-site
ahoy test-bdd
