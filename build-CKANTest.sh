#!/bin/bash
#deploy CKAN Test base infrastructure

./build-CKAN.sh vars/CKANTest.yml $bamboo_deploy_environment $@
