data "aws_iam_policy_document" "airflow_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "airflow" {
  name               = "airflow-${var.deployment_identifier}"
  description        = "Role for Airflow to coordinate EMR jobs"
  assume_role_policy = "${data.aws_iam_policy_document.airflow_assume_role.json}"
}

resource "aws_iam_instance_profile" "airflow" {
  name = "airflow-${var.deployment_identifier}"
  role = "${aws_iam_role.airflow.name}"
}

data "aws_iam_policy_document" "airflow_emr" {
  statement {
    actions = [
      "elasticmapreduce:DescribeCluster",
      "elasticmapreduce:AddJobFlowSteps",
      "elasticmapreduce:DescribeStep"
    ]

    # For whatever mysterious reason, EMR doesn't support IAM resources
    resources = ["*"]

    # Use tags instead
    condition {
      test     = "StringEquals"
      variable = "elasticmapreduce:ResourceTag/Name"
      values   = ["${var.emr_cluster_name}"]
    }
  }
}

resource "aws_iam_policy" "airflow_emr" {
  name        = "airflow-emr-${var.deployment_identifier}"
  description = "Policy for Airflow to submit jobs to ${var.emr_cluster_name}"
  policy      = "${data.aws_iam_policy_document.airflow_emr.json}"
}

resource "aws_iam_policy_attachment" "airflow_emr" {
  name       = "airflow-emr-${var.deployment_identifier}"
  roles      = ["${aws_iam_role.airflow.name}"]
  policy_arn = "${aws_iam_policy.airflow_emr.arn}"
}

data "aws_iam_policy_document" "airflow_parameter_store" {
  statement {
    actions = [
      "ssm:GetParameters"
    ]

    resources = [
      "arn:aws:ssm:${local.region}:${local.account_id}:parameter/${var.rds_snapshot_password_parameter}"
    ]
  }
}

resource "aws_iam_policy" "airflow_parameter_store" {
  name        = "airflow-parameter-store-${var.deployment_identifier}"
  description = "Policy allowng Airflow to read ${var.rds_snapshot_password_parameter} from Parameter Store"
  policy      = "${data.aws_iam_policy_document.airflow_parameter_store.json}"
}

resource "aws_iam_policy_attachment" "airflow_parameter_store" {
  name       = "airflow-parameter-store-${var.deployment_identifier}"
  roles      = ["${aws_iam_role.airflow.name}"]
  policy_arn = "${aws_iam_policy.airflow_parameter_store.arn}"
}
