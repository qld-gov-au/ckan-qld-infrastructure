# ckan-aws-templates

Author: qol.development@smartservice.qld.gov.au

**Full one click deployment of Datashared AWS OpsWorks Stack via Ansible**

This stands up the www.data.qld.gov.au and www.publications.qld.gov.au aws stacks using:
* SSM
* RDS
* Redis Cluster
* OpsWorks
* Cloudfront with Lambda@Edge
* and may more features

**Features:**

* Single click Enterprise grade CKAN deployment
* User selectable VPC.
* HA DB and Web nodes.
* AWS RDS for Postgres
* User selectable instance and data volume sizes

**Cloudfront Lambda @ Edge controls**

For the system to work with updates to the lambda function, you must;
* first add a new version to cloudfront-lambdaAtEdge.cfn.yml which references the changed lambda function (there is no need for a new lambda function)
* export the new version from said cloudformation template
* update the cloudfront.yml ansible script to load the new version property name. 
* you can delete previous versions after a successful real, do note that cloudfront will hold onto a lambda function and versions until its 'replication' finishes.

**QOL 2019 update**

The Datashades-OpsWorks-EFS-CKAN-Stack template has been split, with RDS and EFS setup moving to separate templates including a new VPC template. These multiple templates are handled by 'build.sh', which runs them via Ansible playbooks.

The RDS setup expects the master credentials to already exist in the Systems Manager Parameter Store at '/config/CKAN/[DEV|TRAINING|STAGING|PROD]/db/master_user' and '/config/CKAN/[DEV|TRAINING|STAGING|PROD]/db/master_password'.

var/shared-${service-name} has the basic facts for the n number of environments

**2017 Update**

We've switched back to our more traditional NFS Solr stack for a number of reasons:

GFS has some serious performance issues within larger installs. The read performance on small files is somewhat poor, and write performance is a major issue. NFS is fast, stable and far easier to set up.

SolrCloud didn't deliver the failover capability we'd hoped so we've switched back to single node Solr. With Route53 failover and rsync however, we believe a HA configuration is possible. The scripts support Route53 failover provisioning, but some work remains to actually put this functionality into practise.

The overall setup of the NFS stack is way easier. Here's the nutshell version:

* Create an instance called services1 in the NFS OpsWorks layer. Add this instance to the Solr and Redis layers before starting it.
* Start the services instance you just added to the layers in step one. Wait for it to finish setting up.
* Create an instance in the Web layer. Start it up and add it to an ELB, or set up a DNS record directly to its IP.

Common issues during set up are as follows:

* yum-cron package doesn't install sometimes due to issues with mirrors. Go to Deployments and repeat setup. This will usually see a clear run through.
* repo issues: Usually related to bad private keys or repo URLs
* Application sources: Check ckan and Solr sources. Solr in particular changes frequently.

**Assumptions:**

It's assumed that you:

* have a pretty good working knowledge of AWS, CloudFormation, OpsWorks, and CKAN and its requirements such as Solr and Postgres. Those will be necessary to troubleshoot builds when you haven't provided the correct parameters or some other obstacle gets in your way.
* have built, installed and successfully run CKAN manually on some kind of single node configuration. If not, this stack isn't designed to be something to cut your teeth on. It's been designed to be relatively foolproof, but not completely so.
* know your way around the Linux command line reasonably well and know how to deal with error logs, dependency conflicts etc.

Installation
------------
Ensure you set ssm params:
* /config/CKAN/GaIdNonProduction
* /config/CKAN/GaIdProduction
* /config/CKAN/GtmIdNonProduction
* /config/CKAN/GtmIdProduction
* /config/CKAN/cicdIpA
* /config/CKAN/cicdIpB
* /config/CKAN/cicdSecurityGroup
* /config/CKAN/ec2KeyPair
* /config/CKAN/opsVpcAccount
* /config/CKAN/opsVpcCidr
* /config/CKAN/opsVpcId
* /config/CKAN/opsVpcRole
* /config/CKAN/s3LogsBucket
Then per environment (DEV/TRAINING/STAGING/PROD)
* /config/CKAN/DEV/app/ckantest/admin_email
* /config/CKAN/DEV/app/ckantest/admin_password
* /config/CKAN/DEV/app/ckantest/beaker_secret
* /config/CKAN/DEV/app/opendata/admin_email
* /config/CKAN/DEV/app/opendata/admin_password
* /config/CKAN/DEV/app/opendata/beaker_secret
* /config/CKAN/DEV/app/publications/admin_email
* /config/CKAN/DEV/app/publications/admin_password
* /config/CKAN/DEV/app/publications/beaker_secret
* /config/CKAN/DEV/db/ckantest_password
* /config/CKAN/DEV/db/ckantest_user
* /config/CKAN/DEV/db/master_password
* /config/CKAN/DEV/db/master_user
* /config/CKAN/DEV/db/opendata_password
* /config/CKAN/DEV/db/opendata_user
* /config/CKAN/DEV/db/publications_password
* /config/CKAN/DEV/db/publications_user
* /config/CKAN/DEV/smtpRelay/region
* /config/CKAN/DEV/smtpRelay/smtpHost
* /config/CKAN/DEV/smtpRelay/smtpOverride
* /config/CKAN/DEV/smtpRelay/smtpPassword
* /config/CKAN/DEV/smtpRelay/smtpPort
* /config/CKAN/DEV/smtpRelay/smtpUsername

Final Notes
-----------

The Datashades stack as provided by Link Digital has been transformed by Qld Online team and forms the foundations for suppling an open data platform. As such it is very well maintained as its in active use.


I've personally seen a lot of "CKAN in a box" releases using Docker and other approaches. On the whole, these are fantastic for getting your
feet wet without drowning in the deep end. Datashades isn't an attempt to complete or replace any of these approachs. Rather, Datashades is
more of a high availability, "enterprise" stack built to best practise, with independantly scalable layers, easily adpated to CI work flows
and automated system maintenance.

Our hope and expectation is that it benefits the wider Public Data community and progresses the Open Data ideal.

Current AWS costs for 2 CKAN applications by 4 envirionments is just shy of 3k USD a month. 

