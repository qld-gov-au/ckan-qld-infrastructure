const { EC2Client, DescribeTagsCommand } = require('@aws-sdk/client-ec2');
const { SSMClient, GetParametersCommand, SendCommandCommand } = require('@aws-sdk/client-ssm');
const { AutoScalingClient, CompleteLifecycleActionCommand } = require('@aws-sdk/client-auto-scaling');

function recordCompletion(event, success) {
  const instanceId = event['EC2InstanceId'];
  if ('AutoScalingGroupName' in event && 'LifecycleHookName' in event) {
    const autoscaling = new AutoScalingClient();
    const autoscalingGroupName = event['AutoScalingGroupName'];
    const lifecycleHookName = event['LifecycleHookName'];
    return autoscaling.send(new CompleteLifecycleActionCommand({
      AutoScalingGroupName: autoscalingGroupName,
      LifecycleHookName: lifecycleHookName,
      InstanceId: instanceId,
      LifecycleActionResult: success? "CONTINUE" : "ABANDON"
    }));
  } else {
    return Promise.resolve({"success": success});
  }
}

exports.handler = async (event) => {
  const instanceId = event['EC2InstanceId'];
  const deployPhase = 'phase' in event ? event['phase'] : 'setup';
  if (!['setup', 'deploy', 'configure'].includes(deployPhase)) {
    console.log("Invalid deployment phase '" + deployPhase + "', must be one of 'setup', 'deploy', 'configure'");
    return recordCompletion(event, false);
  }
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
    return recordCompletion(event, false);
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
    return recordCompletion(event, false);
  }
  var sourceInfo;
  if (cookbookType == 'git') {
    if (!cookbookRevision) {
      console.log("Missing cookbook revision");
      return recordCompletion(event, false);
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
  var runList = `recipe[${recipePrefix}-configure]`;
  if (deployPhase !== 'configure') {
    runList = `recipe[${recipePrefix}-deploy],${runList}`;
  }
  if (deployPhase === 'setup') {
    runList = `recipe[${recipePrefix}-setup],${runList}`;
  }

  await ssm.send(new SendCommandCommand({
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

  return recordCompletion(event, true);
};
