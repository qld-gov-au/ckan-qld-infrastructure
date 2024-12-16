#!/usr/bin/env sh
##
# Create example content specific to Publications BDD tests.
#
set -e
set -x

# Create publishing standards dataset
api_call '{"name": "publishing-standards-publications-qld-gov-au", "owner_org": "'"${TEST_ORG_ID}"'"}' package_create

# Create private test dataset with our standard fields
api_call '{"name": "test-dataset", "owner_org": "'"${TEST_ORG_ID}"'", "private": true,
"notes": "private test"}' package_create

# Create public test dataset with our standard fields
api_call '{"name": "public-test-dataset", "owner_org": "'"${TEST_ORG_ID}"'",
"notes": "public test", "resources": [
    {"name": "test-resource", "description": "Test resource description",
     "url": "https://example.com", "format": "HTML", "size": 1024}
]}' package_create

