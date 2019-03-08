#!/bin/bash
#deploy Publications base infrastructure

./build-CKAN.sh vars/Publications.yml $bamboo_deploy_environment $1
