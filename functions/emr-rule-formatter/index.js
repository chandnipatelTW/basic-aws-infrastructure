'use strict';

var AWS = require('aws-sdk');
var sns = new AWS.SNS();

exports.handler = (event, context, callback) => {
  var message = event.detail.message
  var topic_arn = process.env.sns_topic_arn

  var publishParams = { 
    TopicArn: topic_arn,
    Message: message
  };

  sns.publish(publishParams, (err, data) => {
    if (err)  console.log(err)
        else  callback(null, "Completed");
  })

  console.log(event)
};