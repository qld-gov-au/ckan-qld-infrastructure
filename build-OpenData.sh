#!/bin/bash
#deploy Open Data base infrastructure

./build-CKAN.sh vars/OpenData.yml $bamboo_deploy_environment $1
