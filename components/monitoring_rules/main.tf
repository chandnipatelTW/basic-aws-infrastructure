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

resource "aws_cloudwatch_event_target" "sns" {
  rule      = "${aws_cloudwatch_event_rule.main.name}"
  target_id = "SendToSNS-${var.cohort}"
  arn       = "${var.sns_alert_topic_arn}"
}
