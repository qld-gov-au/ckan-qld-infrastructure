'use strict';
exports.handler = async (event, context) => {
  const request = event.Records[0].cf.request;
  const s3_pattern = new RegExp('^/ckan-[a-z]+-attachments-[a-z]+/')
  if (s3_pattern.test(request.uri)) {
    request.uri = request.uri.replace(s3_pattern, '/');
  }
  return request;
};
