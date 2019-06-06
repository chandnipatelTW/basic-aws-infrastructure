resource "aws_instance" "airflow" {
  # FIXME: Use a specialised airflow AMI
  ami                    = "${data.aws_ami.amazon_linux_2.image_id}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.airflow.id}"]
  subnet_id              = "${var.subnet_ids[0]}"
  key_name               = "${var.ec2_key_pair}"
  iam_instance_profile   = "${aws_iam_instance_profile.airflow.name}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "airflow-${var.deployment_identifier}"
    )
  )}"

  # TODO: Remove this once we have dedicated airflow AMI
  lifecycle {
    ignore_changes = ["ami"]
  }
}

