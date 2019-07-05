terraform {
  backend "s3" {}
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 2.0"
}

data "terraform_remote_state" "training_emr_cluster" {
  backend = "s3"
  config {
    key    = "training_emr_cluster.tfstate"
    bucket = "tw-dataeng-${var.cohort}-tfstate"
    region = "${var.aws_region}"
  }
}

resource "aws_iam_role" "emr_rule_formatter_lambda_role" {
  name = "lambda-role-${var.cohort}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "emr_rule_formatter_lambda_role_policy" {
  name = "lambda-role-policy-for-sns-and-logs-send"
  role = "${aws_iam_role.emr_rule_formatter_lambda_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "1",
      "Action": [
        "logs:CreateLogGroup",     
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "2",
      "Effect": "Allow",
      "Action": "sns:Publish",
      "Resource": "*"
    }
  ]
}
EOF
}

data "archive_file" "emr_rule_formatter_lambda_archive" {
  type        = "zip"
  source_file = "${path.module}/../../functions/emr-rule-formatter/index.js"
  output_path = "${path.module}/../../functions/emr-rule-formatter/emr-rule-formatter-lambda.zip"
}

resource "aws_lambda_function" "emr_rule_formatter_lambda" {
  function_name    = "emr-rule-formatter-lambda-${var.cohort}"
  handler          = "index.handler"
  runtime          = "nodejs8.10"
  filename         = "${path.module}/../../functions/emr-rule-formatter/emr-rule-formatter-lambda.zip"
  source_code_hash = "${data.archive_file.emr_rule_formatter_lambda_archive.output_base64sha256}"
  role             = "${aws_iam_role.emr_rule_formatter_lambda_role.arn}"
  
  environment {
    variables {
      sns_topic_arn = "${var.sns_alert_topic_arn}"
    }
  }
}

resource "aws_cloudwatch_event_rule" "main" {
  name = "emr-app-failed-${var.cohort}"
  description = "${var.cohort}: Rule that alerts when application fails on EMR"
  event_pattern = <<PATTERN

{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Step Status Change"
  ],
  "detail": {
    "state": [
      "FAILED"
    ],
    "clusterId": [
      "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = "${aws_cloudwatch_event_rule.main.name}"
  target_id = "SendToLambda-${var.cohort}"
  arn       = "${aws_lambda_function.emr_rule_formatter_lambda.arn}"
}
