const { EC2Client, DescribeTagsCommand } = require('@aws-sdk/client-ec2');
const { SSMClient, GetParametersCommand, SendCommandCommand } = require('@aws-sdk/client-ssm');

exports.handler = async (event) => {
  const instanceId = event['instance-id'];
  const ec2 = new EC2Client();
  var environment, service, layer;
  const data = await ec2.send(new DescribeTagsCommand({
    Filters: [
      {
        Name: 'resource-id',
        Values: [instanceId]
      }
    ]
  }));
  for (const tag of data['Tags']) {
    if (tag['Key'] == 'Environment') {
      environment = tag['Value'];
    } else if (tag['Key'] == 'Service') {
      service = tag['Value'].toLowerCase();
    } else if (tag['Key'] == 'Layer') {
      layer = tag['Value'];
    }
  }
  if (!environment || !service || !layer) {
    console.log("Missing tag on target instance; need Environment and Service and Layer");
    return;
  }
  var cookbookType, cookbookURL, cookbookRevision;
  const ssm = new SSMClient();
  const cookbookParameters = await ssm.send(new GetParametersCommand({
    Names: [
      `/config/CKAN/${environment}/app/${service}/cookbook/type`,
      `/config/CKAN/${environment}/app/${service}/cookbook/url`,
      `/config/CKAN/${environment}/app/${service}/cookbook/revision`
    ]
  }));
  for (const parameter of cookbookParameters['Parameters']) {
    if (parameter['Name'].endsWith('/type')) {
      cookbookType = parameter['Value'];
    } else if (parameter['Name'].endsWith('/url')) {
      cookbookURL = parameter['Value'];
    } else if (parameter['Name'].endsWith('/revision')) {
      cookbookRevision = parameter['Value'];
    }
  }
  if (!cookbookURL) {
    console.log("Missing cookbook URL");
    return;
  }
  var sourceInfo;
  if (cookbookType == 'git') {
    if (!cookbookRevision) {
      console.log("Missing cookbook revision");
      return;
    }
    var refType;
    if (/^[0-9.]{5}/.test(cookbookRevision)) {
      refType = 'tags';
    } else {
      refType = 'remotes/origin';
    }
    cookbookType = 'Git';
    sourceInfo = `{\"repository\":\"${cookbookURL}\",\"getOptions\":\"branch:refs/${refType}/${cookbookRevision}\"}`;
  } else if (cookbookType == 's3') {
    cookbookType = 'S3';
    sourceInfo =`{\"path\":\"${cookbookURL}\"}`;
  }
  var recipePrefix;
  if (layer == 'web' || layer == 'batch') {
    recipePrefix = `datashades::ckan${layer}`;
  } else {
    recipePrefix = `datashades::${layer}`;
  }
  const runList=`recipe[${recipePrefix}-setup],recipe[${recipePrefix}-deploy],recipe[${recipePrefix}-configure]`;

  return await ssm.send(new SendCommandCommand({
    DocumentName: "AWS-ApplyChefRecipes",
    DocumentVersion: '\$DEFAULT',
    InstanceIds: [ instanceId ],
    Parameters: {
      SourceType: [cookbookType],
      SourceInfo: [sourceInfo],
      RunList: [runList],
      ChefClientVersion: ["14"],
      WhyRun: ["False"],
      ComplianceSeverity: ["None"],
      ComplianceType: ["Custom:Chef"]
    }
  }));
};
