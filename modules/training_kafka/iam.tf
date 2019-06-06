data "aws_iam_policy_document" "kafka_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "kafka" {
  name               = "kafka-${var.deployment_identifier}"
  description        = "Role for Kafka"
  assume_role_policy = "${data.aws_iam_policy_document.kafka_assume_role.json}"
}

resource "aws_iam_instance_profile" "kafka" {
  name = "kafka-${var.deployment_identifier}"
  role = "${aws_iam_role.kafka.name}"
}

data "aws_iam_policy_document" "kafka_cloudwatch" {
  statement {
    actions = [
      "cloudwatch:PutMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "kafka_cloudwatch" {
  name        = "kafka-emr-${var.deployment_identifier}"
  description = "Policy for kafka to push data to cloudwatch"
  policy      = "${data.aws_iam_policy_document.kafka_cloudwatch.json}"
}

resource "aws_iam_policy_attachment" "kafka_cloudwatch" {
  name       = "kafka-emr-${var.deployment_identifier}"
  roles      = ["${aws_iam_role.kafka.name}"]
  policy_arn = "${aws_iam_policy.kafka_cloudwatch.arn}"
}
