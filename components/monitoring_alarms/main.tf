terraform {
  backend "s3" {}
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 2.0"
}

data "terraform_remote_state" "training_kafka" {
  backend = "s3"
  config {
    key    = "training_kafka.tfstate"
    bucket = "tw-dataeng-${var.cohort}-tfstate"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "training_emr_cluster" {
  backend = "s3"
  config {
    key    = "training_emr_cluster.tfstate"
    bucket = "tw-dataeng-${var.cohort}-tfstate"
    region = "${var.aws_region}"
  }
}

resource "aws_cloudwatch_metric_alarm" "failed_app_alarm" {
  alarm_name = "platform-not-up-for-${var.cohort}",
  alarm_description = "${var.cohort}: Alert for when all of the applications of streaming pipeline are not up"
  comparison_operator = "LessThanThreshold",
  threshold = "5",
  namespace = "AWS/ElasticMapReduce"
  metric_name = "AppsRunning"
  period = "300",
  evaluation_periods = "1",
  datapoints_to_alarm = 1,
  statistic = "Average",
  insufficient_data_actions = [
    "${var.sns_alert_topic_arn}"
  ],
  ok_actions = [],
  alarm_actions = [
    "${var.sns_alert_topic_arn}"
  ],
  dimensions {
    JobFlowId = "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}"
  },
  actions_enabled = true
}

resource "aws_cloudwatch_metric_alarm" "kafka_disc_usage_alarm" {
  alarm_name = "${var.cohort} Kafka Utilization Warning",
  alarm_description = "${var.cohort}: Alert for when kafka disc usage bigger than threshold"
  comparison_operator = "GreaterThanThreshold",
  threshold = "80",
  namespace = "System/Linux"
  metric_name = "DiskSpaceUtilization"
  period = "900",
  evaluation_periods = "1",
  datapoints_to_alarm = 1,
  statistic = "Average",
  insufficient_data_actions = [
    "${var.sns_alert_topic_arn}"
  ],
  ok_actions = [],
  alarm_actions = [
    "${var.sns_alert_topic_arn}"
  ],
  dimensions {
    MountPath = "/",
    InstanceId = "${data.terraform_remote_state.training_kafka.kafka_instance_id}",
    Filesystem = "/dev/xvda1"
  },
  actions_enabled = true
}