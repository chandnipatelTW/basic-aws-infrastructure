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

data "terraform_remote_state" "ingester" {
  backend = "s3"
  config {
    key    = "ingester.tfstate"
    bucket = "tw-dataeng-${var.cohort}-tfstate"
    region = "${var.aws_region}"
  }
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "2wheelers-${var.cohort}"
  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 12,
      "y": 6,
      "width": 6,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [ "System/Linux", "DiskSpaceUtilization", "MountPath", "/", "InstanceId", "${data.terraform_remote_state.training_kafka.kafka_instance_id}", "Filesystem", "/dev/xvda1" ]
        ],
        "region": "${var.aws_region}",
        "period": 300,
        "title": "Kafka | Disc Utilization "
      }
    },
    {
      "type": "metric",
      "x": 18,
      "y": 0,
      "width": 6,
      "height": 3,
      "properties": {
        "metrics": [
          [ "System/Linux", "DiskSpaceAvailable", "MountPath", "/", "InstanceId", "${data.terraform_remote_state.training_kafka.kafka_instance_id}", "Filesystem", "/dev/xvda1", { "stat": "Average", "period": 300, "label": "Available Space" } ]
        ],
        "view": "singleValue",
        "region": "${var.aws_region}",
        "period": 300,
        "title": "Kafka | Available Disc Space"
      }
    },
    {
      "type": "metric",
      "x": 18,
      "y": 3,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [ "System/Linux", "DiskSpaceAvailable", "MountPath", "/", "InstanceId", "${data.terraform_remote_state.training_kafka.kafka_instance_id}", "Filesystem", "/dev/xvda1", { "color": "#ff7f0e", "period": 3600 } ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "${var.aws_region}",
        "title": "Kafka | Available Disc Space",
        "period": 300
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 3,
      "width": 6,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [ "AWS/ElasticMapReduce", "MemoryTotalMB", "JobFlowId", "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}" ],
          [ ".", "MemoryAllocatedMB", ".", "." ],
          [ ".", "MemoryReservedMB", ".", "." ],
          [ ".", "MemoryAvailableMB", ".", "." ]
        ],
        "region": "${var.aws_region}",
        "period": 300,
        "title": "EMR | Memory Usage"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 0,
      "width": 6,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [ "AWS/EC2", "CPUUtilization", "InstanceId", "${data.terraform_remote_state.training_kafka.kafka_instance_id}" ]
        ],
        "region": "${var.aws_region}",
        "title": "Kafka | CPU Utilization",
        "period": 300
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 0,
      "width": 6,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [ "AWS/ElasticMapReduce", "AppsRunning", "JobFlowId", "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}" ]
        ],
        "region": "${var.aws_region}",
        "title": "EMR | Apps Running",
        "period": 300
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 6,
      "height": 3,
      "properties": {
        "view": "singleValue",
        "stacked": false,
        "metrics": [
          [ "AWS/ElasticMapReduce", "YARNMemoryAvailablePercentage", "JobFlowId", "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}" ]
        ],
        "region": "${var.aws_region}",
        "title": "YARN | Available Memory %"
      }
    },
    {
      "type": "metric",
      "x": 6,
      "y": 6,
      "width": 6,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/ElasticMapReduce", "HDFSUtilization", "JobFlowId", "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}", { "stat": "Average" } ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "${var.aws_region}",
        "title": "HDFS | Utilization"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 9,
      "width": 6,
      "height": 3,
      "properties": {
        "view": "singleValue",
        "title": "HDFS | Disc Capacity",
        "metrics": [
          [ "AWS/ElasticMapReduce", "CapacityRemainingGB", "JobFlowId", "${data.terraform_remote_state.training_emr_cluster.emr_cluster_id}" ]
        ],
        "region": "${var.aws_region}"
      }
    },
    {
      "type": "metric",
      "x": 18,
      "y": 9,
      "width": 6,
      "height": 3,
      "properties": {
        "view": "singleValue",
        "metrics": [
          [ "System/Linux", "MemoryUtilization", "InstanceId", "${data.terraform_remote_state.ingester.ingester_instance_id}" ]
        ],
        "region": "${var.aws_region}",
        "period": 300,
        "title": "Ingester | Memory Utilization"
      }
    }
  ]
}
 EOF
}
