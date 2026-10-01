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
  /*
   * Possible deployment types include:
   * - 'setup': Full end-to-end configuration, from vanilla operating system to live instance.
   * - 'deploy': Take a vanilla operating system and set up a warm instance, but do not make it active.
   * - 'configure': Take a warm instance and make it active.
   */
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
  const cookbookBase = '/var/chef/cookbooks';
  var downloadCommands = [
    'dnf upgrade-minimal --security -y',
    `mkdir -p ${cookbookBase}`,
    `rm -rf ${cookbookBase}/datashades`
  ];
  if (cookbookType == 'git') {
    if (!cookbookRevision) {
      console.log("Missing cookbook revision");
      return recordCompletion(event, false);
    }
    downloadCommands.push('which git || dnf install -y git', `git clone --branch "${cookbookRevision}" "${cookbookURL}" ${cookbookBase}/datashades`);
  } else if (cookbookType == 's3') {
    downloadCommands.push(
      `mkdir -p ${cookbookBase}/datashades`,
      `aws s3 cp "${cookbookURL}" ${cookbookBase}/datashades.tgz`,
      `tar -xzf ${cookbookBase}/datashades.tgz -C ${cookbookBase}/datashades`
    );
  }
  var recipePrefix;
  if (layer == 'web' || layer == 'batch') {
    recipePrefix = `datashades::ckan${layer}`;
  } else {
    recipePrefix = `datashades::${layer}`;
  }
  /*
   * Always install security patches, but only reboot if
   * we're starting a live instance, not just prepping.
   */
  var runList = [];
  if (deployPhase !== 'configure') {
    runList.push(`recipe[${recipePrefix}-setup]`, `recipe[${recipePrefix}-deploy]`);
  }
  if (deployPhase !== 'deploy') {
    runList.push(`recipe[${recipePrefix}-configure]`, "recipe[datashades::apply-patch-baseline]");
  }

  await ssm.send(new SendCommandCommand({
    Comment: `Running '${deployPhase}' on ${service} ${environment} instance ${instanceId}`,
    DocumentName: "AWS-RunShellScript",
    DocumentVersion: '\$DEFAULT',
    InstanceIds: [ instanceId ],
    OutputS3BucketName: "osssio-ckan-web-logs",
    OutputS3KeyPrefix: "run_command",
    Parameters: {
      commands: [
        /* Manually download our cookbook, then run Chef Zero */
        ...downloadCommands,
        `chef-client -z -o "${runList.join(',')}"`
      ]
    }
  }));

  return recordCompletion(event, true);
};
