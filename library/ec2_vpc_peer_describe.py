#!/usr/bin/python

DOCUMENTATION = '''
---
module: ec2_vpc_peer_describe
short_description: list vpc peering
description:
    - list vpc peering

options:
  vpc_id:
    description:
      - vpc_id to filter on
    required: true
    default: null
  peer_vpc_id:
    description:
      - peer vpc_id to filter on
    required: false
    default: null
  status:
    descripton:
      - collect single status default active (pending-acceptance, failed, expired, provisioning, active, deleted, rejected)
    required: false
    default: active
    choices: ['pending-acceptance', 'failed', 'expired', 'provisioning', 'active', 'deleted', 'rejected']
author: William Dutton
extends_documentation_fragment: aws
requirements: [ botocore, boto3, json ]
'''

EXAMPLES = '''
# list single vpc peer connection
- ec2_vpc_peer_describe:
    vpc_id: vpc-23234
    peer_vpc_id: vpc-323423
    region: us-east-1

returns:
dict {'changed': False,
    'vpc_peer_connection': {
        'Status': {
            'Message': 'Active',
            'Code': 'active'
            },
        'RequesterVpcInfo': {
            'PeeringOptions': {
                'AllowEgressFromLocalVpcToRemoteClassicLink': False,
                'AllowDnsResolutionFromRemoteVpc': False,
                'AllowEgressFromLocalClassicLinkToRemoteVpc': False
            },
            'OwnerId': '23423',
            'VpcId': 'vpc-vcd',
            'CidrBlock': '10.01.0.0/16'
        },
        'AccepterVpcInfo': {
            'OwnerId': '2341234',
            'VpcId': 'vpc-abc',
            'CidrBlock': '10.0.0.0/16'
        },
        'VpcPeeringConnectionId': u'pcx-asdfasd',
        'Tags': [
            {'Value': 'a', 'Key':'a'},
            {'Value': a name', 'Key': 'Name'},
            {'Value': 'b', 'Key': 'b'}
            ]
        }
    }

# list all vpc peer connections in vpc
- ec2_vpc_peer_describe:
    vpc_id: vpc-23234
    region: us-west-2

returns"
dict { "changed": false,
        "vpc_peer_connections": [
            {
                "AccepterVpcInfo": {
                    "CidrBlock": "10.0.0.0/16",
                    "OwnerId": "1234",
                    "PeeringOptions": {
                        "AllowDnsResolutionFromRemoteVpc": false,
                        "AllowEgressFromLocalClassicLinkToRemoteVpc": false,
                        "AllowEgressFromLocalVpcToRemoteClassicLink": false
                    },
                    "VpcId": "vpc-23234"
                },
                "RequesterVpcInfo": {
                    "CidrBlock": "10.1.0.0/16",
                    "OwnerId": "4321",
                    "VpcId": "vpc-13423"
                },
                "Status": {
                    "Code": "active",
                    "Message": "Active"
                },
                "Tags": [
                    {
                        "Key": "Environment",
                        "Value": "something"
                    },
                    {
                        "Key": "Name",
                        "Value": "a name"
                    }
                ],
                "VpcPeeringConnectionId": "pcx-546452"
            },
            {
                "AccepterVpcInfo": {
                    "CidrBlock": "10.2.0.0/16",
                    "OwnerId": "6345345",
                    "PeeringOptions": {
                        "AllowDnsResolutionFromRemoteVpc": false,
                        "AllowEgressFromLocalClassicLinkToRemoteVpc": false,
                        "AllowEgressFromLocalVpcToRemoteClassicLink": false
                    },
                    "VpcId": "vpc-23234"
                },
                "RequesterVpcInfo": {
                    "CidrBlock": "10.2.0.0/16",
                    "OwnerId": "43532",
                    "VpcId": "vpc-345344"
                },
                "Status": {
                    "Code": "active",
                    "Message": "Active"
                },
                "Tags": [
                    {
                        "Key": "Environment",
                        "Value": "something"
                    },
                    {
                        "Key": "Name",
                        "Value": "a name"
                    }
                ],
                "VpcPeeringConnectionId": "pcx-345345"
            }
        ]
    }


# list all vpc peer connections in vpc which are pending-acceptance
- ec2_vpc_peer_describe:
    vpc_id: vpc-23234
    status: pending-acceptance
    region: us-west-2

'''

try:
    import json
    import botocore
    import boto3
    HAS_BOTO3 = True
except ImportError:
    HAS_BOTO3 = False


def get_peer_connection(vpc, status, vpc_id, peer_vpc_id):
    result = vpc.describe_vpc_peering_connections(Filters=[
        {'Name': 'requester-vpc-info.vpc-id', 'Values': [vpc_id]},
        {'Name': 'accepter-vpc-info.vpc-id', 'Values': [peer_vpc_id]},
        {'Name': 'status-code', 'Values' : [status]}
    ])
    if result['VpcPeeringConnections'] == []:
        result = vpc.describe_vpc_peering_connections(Filters=[
            {'Name': 'requester-vpc-info.vpc-id', 'Values': [peer_vpc_id]},
            {'Name': 'accepter-vpc-info.vpc-id', 'Values': [vpc_id]},
            {'Name': 'status-code', 'Values' : [status]}
        ])

    return None if len(result['VpcPeeringConnections']) != 1 else result['VpcPeeringConnections'][0]

def list_peer_connections(vpc, status, vpc_id):
    result = vpc.describe_vpc_peering_connections(Filters=[
        {'Name': 'requester-vpc-info.vpc-id', 'Values': [vpc_id]},
        {'Name': 'status-code', 'Values' : [status]}
    ])
    if result['VpcPeeringConnections'] == []:
        result = vpc.describe_vpc_peering_connections(Filters=[
            {'Name': 'accepter-vpc-info.vpc-id', 'Values': [vpc_id]},
            {'Name': 'status-code', 'Values' : [status]}
        ])

    return result['VpcPeeringConnections']

def main():
    argument_spec = ec2_argument_spec()
    argument_spec.update(dict(
        vpc_id       = dict(),
        peer_vpc_id  = dict(),
        status       = dict(choices=['pending-acceptance', 'failed', 'expired', 'provisioning', 'active', 'deleted', 'rejected'], default='active')
    ),
    )
    module = AnsibleModule(argument_spec=argument_spec, supports_check_mode=True)

    if not HAS_BOTO3:
        module.fail_json(msg='json, botocore and boto3 are required.')

    vpc_id = module.params['vpc_id']
    peer_vpc_id = module.params['peer_vpc_id']
    status = module.params['status']

    if vpc_id is None:
        module.fail_json('Module parameter "vpc_id"')

    result = {}
    region, ec2_url, aws_connect_kwargs = get_aws_connection_info(module, boto3=True)

    try:
        client = boto3_conn(module, conn_type='client', resource='ec2', region=region, endpoint=ec2_url, **aws_connect_kwargs)
    except botocore.exceptions.NoCredentialsError as e:
        module.fail_json(msg="Can't authorize connection - "+str(e))
    except Exception, e:
        module.fail_json(msg='Failed to connect to VPC: %s' % str(e))

    if peer_vpc_id is None:
        results = list_peer_connections(client, status, vpc_id)
        result = dict(changed=False, vpc_peer_connections=results)
    else:
        results = get_peer_connection(client, status, vpc_id, peer_vpc_id)
        result = dict(changed=False, vpc_peer_connection=results)

    module.exit_json(**result)


# import module snippets
from ansible.module_utils.basic import *
from ansible.module_utils.ec2 import *

main()