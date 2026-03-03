/*
 * This function strips the name of an S3 bucket out of the URL,
 * before passing the request upstream. This is needed because
 * CloudFront can only add a prefix to the request, not remove one.
 * We want eg '/ckan-opendata-attachments-prod/resources/foo' to serve
 * the 'resources/foo' object from bucket 'ckan-opendata-attachments-prod'.
 */

'use strict';
exports.handler = (event, context, callback) => {
  const request = event.Records[0].cf.request;
  const s3_pattern = new RegExp('^/ckan-[a-z]+-attachments-[a-z]+/')
  if (s3_pattern.test(request.uri)) {
    request.uri = request.uri.replace(s3_pattern, '/');
  }
  callback( null, request );
};
