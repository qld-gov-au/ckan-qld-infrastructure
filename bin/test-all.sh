#!/usr/bin/env bash
##
# Run tests in CI.
#
set -e

./test-lint.sh

./test.sh ||  (ahoy logs; exit 1)

./test-bdd.sh ||  (ahoy logs; exit 1)


