'use strict';
/*Viewer Request
https://github.com/grrr-amsterdam/host-redirect-microservice/blob/master/src/redirect.js
and https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-examples.html#lambda-examples-query-string-examples
without removing capital case
*/

const querystring = require('querystring');

exports.handler = (event, context, callback) => {
    const request = event.Records[0].cf.request;
    /* When you configure a distribution to forward query strings to the origin and
     * to cache based on a whitelist of query string parameters, we recommend
     * the following to improve the cache-hit ratio:
     * - Always list parameters in the same order.
     *
     * This function normalizes query strings so that parameter names and values
     * are lowercase and parameter names are in alphabetical order.
     *
     * For more information, see:
     * http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/QueryStringParameters.html
     */

    //console.log('Query String: ', request.querystring);

    /* Parse request query string to get javascript object */
    const params = querystring.parse(request.querystring);
    const sortedParams = {};

    /* Sort param keys */
    Object.keys(params).sort().forEach(key => {
        sortedParams[key] = params[key];
    });

    /* Update request querystring with normalized  */
    request.querystring = querystring.stringify(sortedParams);

    /* redirect www to root domain */
    if ((request.headers.host[0].value === 'data.qld.gov.au' || request.headers.host[0].value === 'publications.qld.gov.au' ) && request.method !== 'POST') {
        let alternativeHostname = 'www.' + request.headers.host[0].value;
        let redirect = {
            status: '301',
            statusDescription: `Redirecting to apex domain`,
            headers: {
                location: [{
                    key: 'Location',
                    value: `https://${alternativeHostname}${request.uri}${request.querystring ? '?' + request.querystring : ''}`
                }]
            }
        };
        //302 redirect
        callback(null, redirect);
    } else {
        //passthrough with normalized querystring params
        callback(null, request);
    }
};
