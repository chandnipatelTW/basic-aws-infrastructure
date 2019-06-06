resource "aws_instance" "ingester" {
  ami                         = "${data.aws_ami.training_ingester.image_id}"
  instance_type               = "${var.instance_type}"
  vpc_security_group_ids      = ["${aws_security_group.ingester.id}"]
  subnet_id                   = "${var.subnet_id}"
  key_name                    = "${var.ec2_key_pair}"
  associate_public_ip_address = true
  user_data                   = "${data.template_cloudinit_config.ingester.rendered}"

  iam_instance_profile = "${aws_iam_instance_profile.ingester.name}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "ingester-${var.deployment_identifier}"
    )
  )}"
}

output "ingester_instance_id" {
  description = "The instance id."
  value       = "${aws_instance.ingester.id}"
}


data "aws_iam_policy_document" "ingester_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ingester_cloudwatch" {
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
resource "aws_iam_role" "ingester" {
  name               = "ingester-${var.deployment_identifier}"
  description        = "Role for ingester"
  assume_role_policy = "${data.aws_iam_policy_document.ingester_assume_role.json}"
}
resource "aws_iam_instance_profile" "ingester" {
  name = "ingester-${var.deployment_identifier}"
  role = "${aws_iam_role.ingester.name}"
}

resource "aws_iam_policy" "ingester_cloudwatch" {
  name        = "ingester-${var.deployment_identifier}"
  description = "Policy for ingester to push data to cloudwatch"
  policy      = "${data.aws_iam_policy_document.ingester_cloudwatch.json}"
}
resource "aws_iam_policy_attachment" "ingester_cloudwatch" {
  name       = "ingester-emr-${var.deployment_identifier}"
  roles      = ["${aws_iam_role.ingester.name}"]
  policy_arn = "${aws_iam_policy.ingester_cloudwatch.arn}"
}
